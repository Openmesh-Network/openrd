// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OpenmeshENSReverseClaimable} from "../lib/openmesh-admin/src/OpenmeshENSReverseClaimable.sol";

import {ITasks, IERC20, Escrow} from "./ITasks.sol";
import {TasksUtils, SafeERC20} from "./TasksUtils.sol";

contract Tasks is TasksUtils, OpenmeshENSReverseClaimable {
    using SafeERC20 for IERC20;

    /// @notice The incremental ID for tasks.
    uint256 internal taskCounter;

    /// @notice A mapping between task IDs and task information.
    mapping(uint256 => Task) private tasks;

    /// @notice The base escrow contract that will be cloned for every task.
    address internal immutable escrowImplementation;

    constructor() OpenmeshENSReverseClaimable() {
        escrowImplementation = address(new Escrow());
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
        taskId = taskCounter++;
        Task storage task = tasks[taskId];
        task.metadata = _metadata;
        task.deadline = _deadline;
        Escrow escrow = Escrow(payable(clone(escrowImplementation)));
        escrow.__Escrow_init{value: msg.value}();
        task.escrow = escrow;

        // Gas optimization
        uint96 msgValue = _toUint96(msg.value);
        if (msg.value != 0) {
            task.nativeBudget = msgValue;
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

        task.manager = _manager;
        if (_disputeManager != address(0)) {
            task.disputeManager = _disputeManager;
        }
        task.creator = msg.sender;

        // Default values are already correct (save gas)
        // task.state = TaskState.Open;

        emit TaskCreated(taskId, _metadata, _deadline, _manager, _disputeManager, msg.sender, msgValue, _budget, escrow);

        // Gas optimization
        if (_preapprove.length != 0) {
            task.applicationCount = _toUint32(_preapprove.length);
            for (uint32 i; i < uint32(_preapprove.length);) {
                Application storage application = task.applications[i];
                application.applicant = _preapprove[i].applicant;
                application.accepted = true;
                _ensureRewardEndsWithNextToken(_preapprove[i].reward);
                _setRewardBellowBudget(task, application, _preapprove[i].nativeReward, _preapprove[i].reward);

                emit ApplicationCreated(
                    taskId, i, "", _preapprove[i].applicant, _preapprove[i].nativeReward, _preapprove[i].reward
                );
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
        NativeReward[] calldata _nativeReward,
        Reward[] calldata _reward
    ) external returns (uint32 applicationId) {
        Task storage task = _getTask(_taskId);
        _ensureTaskIsOpen(task);
        _ensureRewardEndsWithNextToken(_reward);

        applicationId = task.applicationCount++;
        Application storage application = task.applications[applicationId];
        application.metadata = _metadata;
        application.applicant = msg.sender;

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

        emit ApplicationCreated(_taskId, applicationId, _metadata, msg.sender, _nativeReward, _reward);
    }

    /// @inheritdoc ITasks
    function acceptApplications(uint256 _taskId, uint32[] calldata _applicationIds) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskIsOpen(task);
        _ensureSenderIsManager(task);

        for (uint32 i; i < _applicationIds.length;) {
            _ensureApplicationExists(task, _applicationIds[i]);

            Application storage application = task.applications[_applicationIds[i]];
            _ensureRewardBellowBudget(
                task,
                application.nativeRewardCount,
                application.rewardCount,
                application.nativeReward,
                application.reward
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
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);
        _ensureSenderIsExecutor(task);

        submissionId = task.submissionCount++;
        Submission storage submission = task.submissions[submissionId];
        submission.metadata = _metadata;

        emit SubmissionCreated(_taskId, submissionId, _metadata);
    }

    /// @inheritdoc ITasks
    function reviewSubmission(
        uint256 _taskId,
        uint8 _submissionId,
        SubmissionJudgement _judgement,
        string calldata _feedback
    ) external {
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
            emit TaskCompleted(_taskId, TaskCompletionSource.SubmissionAccepted);
        }

        emit SubmissionReviewed(_taskId, _submissionId, _judgement, _feedback);
    }

    /// @inheritdoc ITasks
    function cancelTask(uint256 _taskId, string calldata _metadata) external returns (uint8 cancelTaskRequestId) {
        Task storage task = _getTask(_taskId);
        _ensureTaskNotClosed(task);
        _ensureSenderIsManager(task);

        if (task.state == TaskState.Open || task.deadline <= uint64(block.timestamp)) {
            // Task is open or deadline past
            _refundCreator(task);

            emit TaskCancelled(_taskId, _metadata);

            // Max means no request
            cancelTaskRequestId = type(uint8).max;
        } else {
            // Task is taken and deadline has not past
            cancelTaskRequestId = task.cancelTaskRequestCount++; // Will overflow if it would be max (guarantees max means no request)
            CancelTaskRequest storage request = task.cancelTaskRequests[cancelTaskRequestId];
            request.metadata = _metadata;

            emit CancelTaskRequested(_taskId, cancelTaskRequestId, _metadata);
        }
    }

    /// @inheritdoc ITasks
    function acceptRequest(uint256 _taskId, RequestType _requestType, uint8 _requestId, bool _execute) external {
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

                emit TaskCancelled(_taskId, cancelTaskRequest.metadata);
                cancelTaskRequest.request.executed = true;

                emit RequestExecuted(_taskId, _requestType, _requestId, msg.sender);
            }
        }

        emit RequestAccepted(_taskId, _requestType, _requestId);
    }

    /// @inheritdoc ITasks
    function executeRequest(uint256 _taskId, RequestType _requestType, uint8 _requestId) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);

        //if (_requestType == RequestType.CancelTask) {
        {
            _ensureCancelTaskRequestExists(task, _requestId);

            CancelTaskRequest storage cancelTaskRequest = task.cancelTaskRequests[_requestId];
            _ensureRequestAccepted(cancelTaskRequest.request);
            _ensureRequestNotExecuted(cancelTaskRequest.request);

            _refundCreator(task);

            emit TaskCancelled(_taskId, cancelTaskRequest.metadata);
            cancelTaskRequest.request.executed = true;
        }

        emit RequestExecuted(_taskId, _requestType, _requestId, msg.sender);
    }

    /// @inheritdoc ITasks
    function extendDeadline(uint256 _taskId, uint64 _extension) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskNotClosed(task);
        _ensureSenderIsManager(task);

        task.deadline += _extension;

        emit DeadlineChanged(_taskId, task.deadline);
    }

    /// @inheritdoc ITasks
    function increaseBudget(uint256 _taskId, uint96[] calldata _increase) external payable {
        Task storage task = _getTask(_taskId);
        _ensureTaskNotClosed(task);
        _ensureSenderIsManager(task);

        _increaseNativeBudget(task);
        _increaseBudget(task, _increase);

        emit BudgetChanged(_taskId);
    }

    /// @inheritdoc ITasks
    function increaseReward(
        uint256 _taskId,
        uint32 _applicationId,
        uint96[] calldata _nativeIncrease,
        uint88[] calldata _increase
    ) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskNotClosed(task);
        _ensureSenderIsManager(task);

        _ensureApplicationExists(task, _applicationId);
        Application storage application = task.applications[_applicationId];
        uint8 nativeRewardCount = application.nativeRewardCount;
        for (uint8 i; i < nativeRewardCount;) {
            application.nativeReward[i].amount += _nativeIncrease[i];
            unchecked {
                ++i;
            }
        }
        uint8 rewardCount = application.rewardCount;
        for (uint8 i; i < rewardCount;) {
            application.reward[i].amount += _increase[i];
            unchecked {
                ++i;
            }
        }
        _ensureRewardBellowBudget(task, nativeRewardCount, rewardCount, application.nativeReward, application.reward);

        emit RewardIncreased(_taskId, _applicationId, _nativeIncrease, _increase);
    }

    /// @inheritdoc ITasks
    function editMetadata(uint256 _taskId, string calldata _newMetadata) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskIsOpen(task);
        _ensureSenderIsManager(task);

        task.metadata = _newMetadata;

        emit MetadataChanged(_taskId, _newMetadata);
    }

    /// @inheritdoc ITasks
    function transferManagement(uint256 _taskId, address _newManager) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskNotClosed(task);
        _ensureSenderIsManager(task);

        task.manager = _newManager;

        emit ManagerChanged(_taskId, _newManager);
    }

    /// @inheritdoc ITasks
    function completeByDispute(
        uint256 _taskId,
        uint96[] calldata _partialNativeReward,
        uint88[] calldata _partialReward
    ) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);
        _ensureSenderIsDisputeManager(task);

        _payoutTaskPartially(task, _partialNativeReward, _partialReward);
        _refundCreator(task);

        emit PartialPayment(_taskId, _partialNativeReward, _partialReward);
        emit TaskCompleted(_taskId, TaskCompletionSource.Dispute);
    }

    /// @inheritdoc ITasks
    function partialPayment(uint256 _taskId, uint96[] calldata _partialNativeReward, uint88[] calldata _partialReward)
        external
    {
        Task storage task = _getTask(_taskId);
        _ensureTaskIsTaken(task);
        _ensureSenderIsManager(task);

        _payoutTaskPartially(task, _partialNativeReward, _partialReward);

        emit BudgetChanged(_taskId);
        emit PartialPayment(_taskId, _partialNativeReward, _partialReward);
    }

    // To save any native funds stuck in the escrow
    function rescueNative(uint256 _taskId, address payable to, uint256 amount) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskClosed(task);
        _ensureSenderIsManager(task);

        task.escrow.transferNative(to, amount);
    }

    // To save any erc20 funds stuck in the escrow
    function rescue(uint256 _taskId, IERC20 token, address to, uint256 amount) external {
        Task storage task = _getTask(_taskId);
        _ensureTaskClosed(task);
        _ensureSenderIsManager(task);

        task.escrow.transfer(token, to, amount);
    }

    function _getTask(uint256 _taskId) internal view returns (Task storage task) {
        if (_taskId >= taskCounter) {
            revert TaskDoesNotExist();
        }

        task = tasks[_taskId];
    }
}
