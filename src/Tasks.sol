// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ITasks, IERC20, Escrow} from "./ITasks.sol";
import {TasksUtils, SafeERC20} from "./TasksUtils.sol";

contract Tasks is TasksUtils {
    using SafeERC20 for IERC20;

    /// @notice The incremental ID for tasks.
    uint256 private taskCounter;

    /// @notice A mapping between task IDs and task information.
    mapping(uint256 => Task) internal tasks;

    /// @notice The base escrow contract that will be cloned for every task.
    address public immutable escrowImplementation;

    /// @notice This address has the power to disable the contract, in case an exploit is discovered.
    address private disabler;

    error Disabled();
    error NotDisabled();
    error NotDisabler();

    constructor(address _disabler) {
        escrowImplementation = address(new Escrow());
        disabler = _disabler;
    }

    /// @inheritdoc ITasks
    function taskCount() external view returns (uint256) {
        return taskCounter;
    }

    /// @inheritdoc ITasks
    function getTask(uint256 _taskId) public view returns (OffChainTask memory offchainTask) {
        Task storage task = _getTask(_taskId);
        offchainTask = _toOffchainTask(task);
    }

    /// @inheritdoc ITasks
    function getTasks(uint256[] memory _taskIds) external view returns (OffChainTask[] memory) {
        OffChainTask[] memory offchainTasks = new OffChainTask[](_taskIds.length);
        for (uint256 i; i < _taskIds.length;) {
            offchainTasks[i] = getTask(_taskIds[i]);

            unchecked {
                ++i;
            }
        }
        return offchainTasks;
    }

    /// @inheritdoc ITasks
    function createTask(
        string calldata _metadata,
        uint64 _deadline,
        address _manager,
        address _disputeManager,
        ERC20Transfer[] calldata _budget,
        PreapprovedApplication[] calldata _preapprove
    ) external payable returns (uint256 taskId) {
        _ensureNotDisabled();
        taskId = taskCounter++;

        Task storage task = tasks[taskId];
        task.metadata = _metadata;
        task.deadline = _deadline;
        {
            Escrow escrow = Escrow(payable(clone(escrowImplementation)));
            escrow.__Escrow_init{value: msg.value}();
            task.escrow = escrow;

            // Gas optimization
            if (msg.value != 0) {
                task.nativeBudget = _toUint96(msg.value);
            }
            // Gas optimization
            if (_budget.length != 0) {
                task.budgetCount = _toUint8(_budget.length);
                for (uint8 i; i < uint8(_budget.length);) {
                    // Please mind that this external user specified "token contract" could be used for reentrancies. As all funds are held in seperate escrows (this contract has none), this should not be an issue.
                    // Possible "attack": create an application, accept it and take the task inside the safeTransferFrom call, the preapproved application can be used to overwrite the reward (although limited by the budget).
                    // This all happens in a single transaction, which means realistically the proposer could achieve the same result anyhow.
                    _budget[i].tokenContract.safeTransferFrom(msg.sender, address(escrow), _budget[i].amount);
                    // use balanceOf in case there is a fee assosiated with the transfer
                    task.budget[i] = ERC20Transfer(
                        _budget[i].tokenContract, _toUint96(_budget[i].tokenContract.balanceOf(address(escrow)))
                    );
                    unchecked {
                        ++i;
                    }
                }
            }
        }

        task.manager = _manager;
        task.creator = msg.sender;
        if (_disputeManager != address(0)) {
            task.disputeManager = _disputeManager;
        }

        // Default values are already correct (save gas)
        // task.state = TaskState.Open;

        emit TaskCreated(
            taskId, _metadata, _deadline, _budget, _toUint96(msg.value), msg.sender, _manager, _disputeManager
        );

        // Gas optimization
        if (_preapprove.length != 0) {
            task.applicationCount = _toUint32(_preapprove.length);
            for (uint32 i; i < uint32(_preapprove.length);) {
                Application storage application = task.applications[i];
                application.applicant = _preapprove[i].applicant;
                application.accepted = true;
                _ensureRewardEndsWithNextToken(_preapprove[i].reward);
                _setRewardBellowBudget(task, application, _preapprove[i].reward, _preapprove[i].nativeReward);

                emit ApplicationCreated(taskId, i, "", _preapprove[i].reward, _preapprove[i].nativeReward);

                emit ApplicationAccepted(taskId, i);

                unchecked {
                    ++i;
                }
            }
        }
    }

    /// @inheritdoc ITasks
    function applyForTask(
        uint256 _taskId,
        string calldata _metadata,
        Reward[] calldata _reward,
        NativeReward[] calldata _nativeReward
    ) external returns (uint32 applicationId) {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsOpen(task);
        _ensureRewardEndsWithNextToken(_reward);

        Application storage application = task.applications[task.applicationCount];
        application.metadata = _metadata;
        application.applicant = msg.sender;

        // Gas optimization
        if (_reward.length != 0) {
            application.rewardCount = _toUint8(_reward.length);
            for (uint8 i; i < uint8(_reward.length);) {
                application.reward[i] = _reward[i];
                unchecked {
                    ++i;
                }
            }
        }

        // Gas optimization
        if (_nativeReward.length != 0) {
            application.nativeRewardCount = _toUint8(_nativeReward.length);
            for (uint8 i; i < uint8(_nativeReward.length);) {
                application.nativeReward[i] = _nativeReward[i];
                unchecked {
                    ++i;
                }
            }
        }

        applicationId = task.applicationCount++;

        emit ApplicationCreated(_taskId, applicationId, _metadata, _reward, _nativeReward);
    }

    /// @inheritdoc ITasks
    function acceptApplications(uint256 _taskId, uint32[] calldata _applicationIds) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsOpen(task);
        _ensureSenderIsManager(task);

        for (uint256 i; i < _applicationIds.length;) {
            _ensureApplicationExists(task, _applicationIds[i]);

            Application storage application = task.applications[_applicationIds[i]];
            _ensureRewardBellowBudget(
                task,
                application.rewardCount,
                application.nativeRewardCount,
                application.reward,
                application.nativeReward
            );
            application.accepted = true;

            emit ApplicationAccepted(_taskId, _applicationIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc ITasks
    function takeTask(uint256 _taskId, uint32 _applicationId) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsOpen(task);
        _ensureApplicationExists(task, _applicationId);

        Application storage application = task.applications[_applicationId];
        _ensureSenderIsApplicant(application);
        _ensureApplicationIsAccepted(application);

        task.executorApplication = _applicationId;
        task.state = TaskState.Taken;

        emit TaskTaken(_taskId, _applicationId);
    }

    /// @inheritdoc ITasks
    function createSubmission(uint256 _taskId, string calldata _metadata) external returns (uint8 submissionId) {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);
        _ensureSenderIsExecutor(task);

        Submission storage submission = task.submissions[task.submissionCount];
        submission.metadata = _metadata;
        submissionId = task.submissionCount++;

        emit SubmissionCreated(_taskId, submissionId, _metadata);
    }

    /// @inheritdoc ITasks
    function reviewSubmission(
        uint256 _taskId,
        uint8 _submissionId,
        SubmissionJudgement _judgement,
        string calldata _feedback
    ) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);
        _ensureSenderIsManager(task);
        _ensureSubmissionExists(task, _submissionId);

        Submission storage submission = task.submissions[_submissionId];
        _ensureSubmissionNotJudged(submission);
        _ensureJudgementNotNone(_judgement);
        submission.judgement = _judgement;
        submission.feedback = _feedback;

        if (_judgement == SubmissionJudgement.Accepted) {
            _payoutTask(task);
            emit TaskCompleted(_taskId, TaskCompletion.SubmissionAccepted);
        }

        emit SubmissionReviewed(_taskId, _submissionId, _judgement, _feedback);
    }

    /// @inheritdoc ITasks
    function cancelTask(uint256 _taskId, string calldata _explanation) external returns (uint8 cancelTaskRequestId) {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsManager(task);

        _ensureTaskNotClosed(task);

        if (task.state == TaskState.Open || task.deadline <= uint64(block.timestamp)) {
            // Task is open or deadline past
            _refundCreator(task);

            emit TaskCancelled(_taskId);

            // Max means no request
            cancelTaskRequestId = type(uint8).max;
        } else {
            // Task is taken and deadline has not past
            CancelTaskRequest storage request = task.cancelTaskRequests[task.cancelTaskRequestCount];
            request.explanation = _explanation;
            cancelTaskRequestId = task.cancelTaskRequestCount++; // Will overflow if it would be max (guarantees max means no request)

            emit CancelTaskRequested(_taskId, cancelTaskRequestId, _explanation);
        }
    }

    /// @inheritdoc ITasks
    function acceptRequest(uint256 _taskId, RequestType _requestType, uint8 _requestId, bool _execute) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);
        _ensureSenderIsExecutor(task);

        //if (_requestType == RequestType.CancelTask) {
        {
            _ensureCancelTaskRequestExists(task, _requestId);

            CancelTaskRequest storage cancelTaskRequest = task.cancelTaskRequests[_requestId];
            _ensureRequestNotAccepted(cancelTaskRequest.request);
            cancelTaskRequest.request.accepted = true;

            if (_execute) {
                // use executeRequest in the body instead? (more gas due to all the checks, but less code duplication)
                _refundCreator(task);

                emit TaskCancelled(_taskId);
                cancelTaskRequest.request.executed = true;

                emit RequestExecuted(_taskId, _requestType, _requestId, msg.sender);
            }
        }

        emit RequestAccepted(_taskId, _requestType, _requestId);
    }

    /// @inheritdoc ITasks
    function executeRequest(uint256 _taskId, RequestType _requestType, uint8 _requestId) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);

        //if (_requestType == RequestType.CancelTask) {
        {
            _ensureCancelTaskRequestExists(task, _requestId);

            CancelTaskRequest storage cancelTaskRequest = task.cancelTaskRequests[_requestId];
            _ensureRequestAccepted(cancelTaskRequest.request);
            _ensureRequestNotExecuted(cancelTaskRequest.request);

            _refundCreator(task);

            emit TaskCancelled(_taskId);
            cancelTaskRequest.request.executed = true;
        }

        emit RequestExecuted(_taskId, _requestType, _requestId, msg.sender);
    }

    /// @inheritdoc ITasks
    function extendDeadline(uint256 _taskId, uint64 _extension) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsManager(task);

        _ensureTaskNotClosed(task);

        task.deadline += _extension;

        emit DeadlineChanged(_taskId, task.deadline);
    }

    /// @inheritdoc ITasks
    function increaseBudget(uint256 _taskId, uint96[] calldata _increase) external payable {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsManager(task);

        _ensureTaskIsOpen(task);

        _increaseBudget(task, _increase);
        _increaseNativeBudget(task);

        emit BudgetChanged(_taskId);
    }

    /// @inheritdoc ITasks
    function editMetadata(uint256 _taskId, string calldata _newMetadata) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsManager(task);

        _ensureTaskIsOpen(task);

        task.metadata = _newMetadata;

        emit MetadataChanged(_taskId, _newMetadata);
    }

    /// @inheritdoc ITasks
    function completeByDispute(
        uint256 _taskId,
        uint88[] calldata _partialReward,
        uint96[] calldata _partialNativeReward
    ) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsDisputeManager(task);

        _ensureTaskIsTaken(task);

        _payoutTaskPartially(task, _partialReward, _partialNativeReward);
        _refundCreator(task);

        emit PartialPayment(_taskId, _partialReward, _partialNativeReward);
        emit TaskCompleted(_taskId, TaskCompletion.Dispute);
    }

    /// @inheritdoc ITasks
    function partialPayment(uint256 _taskId, uint88[] calldata _partialReward, uint96[] calldata _partialNativeReward)
        external
    {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsManager(task);

        _ensureTaskIsTaken(task);

        _payoutTaskPartially(task, _partialReward, _partialNativeReward);

        emit BudgetChanged(_taskId);
        emit PartialPayment(_taskId, _partialReward, _partialNativeReward);
    }

    /// @inheritdoc ITasks
    function transferManagement(uint256 _taskId, address _newManager) external {
        _ensureNotDisabled();
        Task storage task = _getTask(_taskId);
        _ensureSenderIsManager(task);

        _ensureTaskNotClosed(task);

        task.manager = _newManager;

        emit NewManager(_taskId, _newManager);
    }

    function disable() external {
        _ensureSenderIsDisabler();
        disabler = address(0);
    }

    // Ideally you are able to transfer the task to a new contract, but that requires adding this to the escrow contract.
    // I prefer this, to keep the escrow contract as simple as possible.
    function refund(uint256 _taskId) external {
        _ensureDisabled();
        Task storage task = _getTask(_taskId);
        _ensureTaskNotClosed(task);
        _refundCreator(task);
    }

    function _getTask(uint256 _taskId) internal view returns (Task storage task) {
        if (_taskId >= taskCounter) {
            revert TaskDoesNotExist();
        }

        task = tasks[_taskId];
    }

    function _ensureNotDisabled() internal view {
        if (disabler == address(0)) {
            revert Disabled();
        }
    }

    function _ensureDisabled() internal view {
        if (disabler != address(0)) {
            revert NotDisabled();
        }
    }

    function _ensureSenderIsDisabler() internal view {
        if (msg.sender != disabler) {
            revert NotDisabler();
        }
    }
}
