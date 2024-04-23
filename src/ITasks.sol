// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Escrow, IERC20} from "./Escrow.sol";

interface ITasks {
    error TaskDoesNotExist();
    error TaskNotOpen();
    error TaskNotTaken();
    error TaskNotClosed();
    error TaskClosed();

    error NotManager();
    error NotExecutor();
    error NotDisputeManager();

    error RewardAboveBudget();
    error RewardDoesntEndWithNextToken();
    error NotEnoughNativeCurrencyAttached();
    error ApplicationDoesNotExist();
    error NotYourApplication();
    error ApplicationNotAccepted();
    error SubmissionDoesNotExist();
    error SubmissionAlreadyJudged();
    error JudgementNone();

    error RequestDoesNotExist();
    error RequestAlreadyAccepted();
    error RequestNotAccepted();
    error RequestAlreadyExecuted();

    error Overflow();
    error ManualBudgetIncreaseNeeded();
    error PartialRewardAboveFullReward();
    error NativeTransferFailed();
    error ERC1167FailedCreateClone();

    // The budget here represents the call of the funder to the escrow, the actual value in the escrow (actual budget) might differ in case of transfer fees / rewards.
    event TaskCreated(
        uint256 indexed taskId,
        string metadata,
        uint64 deadline,
        address manager,
        address disputeManager,
        address creator,
        uint96 nativeBudget,
        ERC20Transfer[] budget,
        Escrow escrow
    );
    event ApplicationCreated(
        uint256 indexed taskId,
        uint32 indexed applicationId,
        string metadata,
        address applicant,
        NativeReward[] nativeReward,
        Reward[] reward
    );
    event ApplicationAccepted(uint256 indexed taskId, uint32 indexed applicationId);
    event TaskTaken(uint256 indexed taskId, uint32 indexed applicationId);
    event SubmissionCreated(uint256 indexed taskId, uint8 indexed submissionId, string metadata);
    event SubmissionReviewed(
        uint256 indexed taskId, uint8 indexed submissionId, SubmissionJudgement judgement, string feedback
    );
    event TaskCompleted(uint256 indexed taskId, TaskCompletionSource source);

    event CancelTaskRequested(uint256 indexed taskId, uint8 indexed requestId, string metadata);
    event TaskCancelled(uint256 indexed taskId, string metadata);
    event RequestAccepted(uint256 indexed taskId, RequestType indexed requestType, uint8 indexed requestId);
    event RequestExecuted(uint256 indexed taskId, RequestType indexed requestType, uint8 indexed requestId, address by);

    event DeadlineChanged(uint256 indexed taskId, uint64 newDeadline);
    event BudgetChanged(uint256 indexed taskId); // Quite expensive to transfer budget into a datastructure to emit
    event RewardIncreased(
        uint256 indexed taskId, uint32 indexed applicationId, uint96[] nativeIncrease, uint88[] increase
    );
    event MetadataChanged(uint256 indexed taskId, string newMetadata);
    event ManagerChanged(uint256 indexed taskId, address newManager);
    event PartialPayment(uint256 indexed taskId, uint96[] partialNativeReward, uint88[] partialReward);

    /// @notice A container for ERC20 transfer information.
    /// @param tokenContract ERC20 token to transfer.
    /// @param amount How much of this token should be transfered. uint96 to keep struct packed into a single uint256.
    struct ERC20Transfer {
        IERC20 tokenContract;
        uint96 amount;
    }

    /// @notice A container for a native reward payout.
    /// @param to Whom the native reward should be transfered to.
    /// @param amount How much native reward should be transfered. uint96 to keep struct packed into a single uint256.
    struct NativeReward {
        address to;
        uint96 amount;
    }

    /// @notice A container for a reward payout.
    /// @param nextToken If this reward is payed out in the next ERC20 token.
    /// @dev IERC20 (address) is a lot of storage, rather just keep those only in budget.
    /// @notice nextToken should always be true for the last entry
    /// @param to Whom this token should be transfered to.
    /// @param amount How much of this token should be transfered. uint88 to keep struct packed into a single uint256.
    struct Reward {
        bool nextToken;
        address to;
        uint88 amount;
    }

    /// @notice A container for a task application.
    /// @param metadata Metadata of the application. (IPFS hash)
    /// @param applicant Who has submitted this application.
    /// @param accepted If the application has been accepted by the manager.
    /// @param nativeReward How much native currency the applicant wants for completion.
    /// @param reward How much rewards the applicant wants for completion.
    struct Application {
        string metadata;
        // Storage block separator
        address applicant;
        bool accepted;
        uint8 nativeRewardCount;
        uint8 rewardCount;
        // Storage block separator
        mapping(uint8 => NativeReward) nativeReward;
        mapping(uint8 => Reward) reward;
    }

    struct OffChainApplication {
        string metadata;
        address applicant;
        bool accepted;
        NativeReward[] nativeReward;
        Reward[] reward;
    }

    /// @notice For approving people on task creation (they are not required to make an application).
    struct PreapprovedApplication {
        address applicant;
        NativeReward[] nativeReward;
        Reward[] reward;
    }

    enum SubmissionJudgement {
        None,
        Accepted,
        Rejected
    }

    /// @notice A container for a task submission.
    /// @param metadata Metadata of the submission. (IPFS hash)
    /// @param judgement Judgement cast on the submission.
    /// @param feedback A response from the manager. (IPFS hash)
    struct Submission {
        string metadata;
        string feedback;
        SubmissionJudgement judgement;
    }

    // This is for future expansion of the request system
    enum RequestType {
        CancelTask
    }

    /// @notice A container for shared request information.
    /// @param accepted If the request was accepted.
    /// @param executed If the request was executed.
    struct Request {
        bool accepted;
        bool executed;
    }

    /// @notice A container for a request to cancel the task.
    /// @param request Request information.
    /// @param metadata Metadata of the request. (IPFS hash, Why the task should be cancelled)
    struct CancelTaskRequest {
        Request request;
        string metadata;
    }

    enum TaskState {
        Open,
        Taken,
        Closed
    }

    /// @notice A container for task-related information.
    /// @param metadata Metadata of the task. (IPFS hash)
    /// @param deadline Block timestamp at which the task expires if not completed.
    /// @param escrow The address of the escrow which holds the budget funds.
    /// @param budget Maximum ERC20 rewards that can be earned by completing the task.
    /// @param nativeBudget Maximum native currency reward that can be earned by completing the task.
    /// @param creator Who has created the task.
    /// @param disputeManager Who has the permission to complete the task without the managers approval.
    /// @param manager Who has the permission to manage the task.
    /// @param state Current state the task is in.
    /// @param applications Applications to take the job.
    /// @param executorApplication Index of the application that will execute the task.
    /// @param submissions Submission made to finish the task.
    struct Task {
        string metadata;
        // Storage block separator
        uint64 deadline;
        Escrow escrow;
        // Storage block separator
        uint96 nativeBudget;
        address creator;
        // Storage block separator
        address disputeManager;
        // Storage block separator
        address manager;
        TaskState state;
        uint32 executorApplication;
        uint8 budgetCount;
        uint32 applicationCount;
        uint8 submissionCount;
        uint8 cancelTaskRequestCount;
        // Storage block separator
        mapping(uint8 => ERC20Transfer) budget;
        mapping(uint32 => Application) applications;
        mapping(uint8 => Submission) submissions;
        mapping(uint8 => CancelTaskRequest) cancelTaskRequests;
    }

    struct OffChainTask {
        string metadata;
        uint64 deadline;
        uint32 executorApplication;
        address manager;
        address disputeManager;
        address creator;
        TaskState state;
        Escrow escrow;
        uint96 nativeBudget;
        ERC20Transfer[] budget;
        OffChainApplication[] applications;
        Submission[] submissions;
        CancelTaskRequest[] cancelTaskRequests;
    }

    enum TaskCompletionSource {
        SubmissionAccepted,
        Dispute
    }

    /// @notice Retrieves the current amount of created tasks.
    function taskCount() external view returns (uint256);

    /// @notice Retrieves all task information by id.
    /// @param _taskId Id of the task.
    function getTask(uint256 _taskId) external view returns (OffChainTask memory);

    /// @notice Retrieves multiple tasks in a single call.
    /// @param _taskIds Ids of the tasks.
    function getTasks(uint256[] calldata _taskIds) external view returns (OffChainTask[] memory);

    /// @notice Create a new task.
    /// @param _metadata Metadata of the task. (IPFS hash)
    /// @param _deadline Block timestamp at which the task expires if not completed.
    /// @param _manager Who will manage the task (become the manager).
    /// @param _disputeManager Who will manage the disputes (handle situations where the manager and executor are in disagreement).
    /// @param _budget Maximum ERC20 rewards that can be earned by completing the task.
    /// @param _preapprove List of addresses (with reward) that are able to take the task without creating an application themselves.
    /// @return taskId Id of the newly created task.
    function createTask(
        string calldata _metadata,
        uint64 _deadline,
        address _manager,
        address _disputeManager,
        ERC20Transfer[] calldata _budget,
        PreapprovedApplication[] calldata _preapprove
    ) external payable returns (uint256 taskId);

    /// @notice Apply to take the task.
    /// @param _taskId Id of the task.
    /// @param _metadata Metadata of your application.
    /// @param _nativeReward Wanted native currency for completing the task.
    /// @param _reward Wanted rewards for completing the task.
    /// @return applicationId Id of the newly created application.
    function applyForTask(
        uint256 _taskId,
        string calldata _metadata,
        NativeReward[] calldata _nativeReward,
        Reward[] calldata _reward
    ) external returns (uint32 applicationId);

    /// @notice Accept application to allow them to take the task.
    /// @param _taskId Id of the task.
    /// @param _applicationIds Indexes of the applications to accept.
    /// @dev Will revert if applicant reward is higher than the budget. increaseBudget should be called beforehand.
    function acceptApplications(uint256 _taskId, uint32[] calldata _applicationIds) external;

    /// @notice Take the task after your application has been accepted.
    /// @param _taskId Id of the task.
    /// @param _applicationId Index of application you made that has been accepted.
    function takeTask(uint256 _taskId, uint32 _applicationId) external;

    /// @notice Create a submission.
    /// @param _taskId Id of the task.
    /// @param _metadata Metadata of the submission. (IPFS hash)
    /// @return submissionId Id of the newly created submission.
    function createSubmission(uint256 _taskId, string calldata _metadata) external returns (uint8 submissionId);

    /// @notice Review a submission.
    /// @param _taskId Id of the task.
    /// @param _submissionId Index of the submission that is reviewed.
    /// @param _judgement Outcome of the review.
    /// @param _feedback Reasoning of the reviewer. (IPFS hash)
    function reviewSubmission(
        uint256 _taskId,
        uint8 _submissionId,
        SubmissionJudgement _judgement,
        string calldata _feedback
    ) external;

    /// @notice Cancels a task. This can be used to close a task and receive back the budget.
    /// @param _taskId Id of the task.
    /// @param _metadata Why the task was cancelled. (IPFS hash)
    /// @return cancelTaskRequestId Id of the newly created request for task cancellation.
    function cancelTask(uint256 _taskId, string calldata _metadata) external returns (uint8 cancelTaskRequestId);

    /// @notice Accepts a request, executing the proposed action.
    /// @param _taskId Id of the task.
    /// @param _requestType What kind of request it is.
    /// @param _requestId Id of the request.
    /// @param _execute If the request should also be executed in this transaction.
    function acceptRequest(uint256 _taskId, RequestType _requestType, uint8 _requestId, bool _execute) external;

    /// @notice Executes an accepted request, allows anyone to pay for the gas costs of the execution.
    /// @param _taskId Id of the task.
    /// @param _requestType What kind of request it is.
    /// @param _requestId Id of the request.
    function executeRequest(uint256 _taskId, RequestType _requestType, uint8 _requestId) external;

    /// @notice Extend the deadline of a task.
    /// @param _taskId Id of the task.
    /// @param _extension How much to extend the deadline by.
    function extendDeadline(uint256 _taskId, uint64 _extension) external;

    /// @notice Increase the budget of the task.
    /// @param _taskId Id of the task.
    /// @param _increase How much to increase each tokens amount by.
    /// @dev Any attached native reward will also be used to increase the budget.
    function increaseBudget(uint256 _taskId, uint96[] calldata _increase) external payable;

    /// @notice Increase the reward of an application of the task.
    /// @param _taskId Id of the task.
    /// @param _applicationId Id of the application.
    /// @param _nativeIncrease How much to increase each native amount by.
    /// @param _increase How much to increase each tokens amount by.
    function increaseReward(
        uint256 _taskId,
        uint32 _applicationId,
        uint96[] calldata _nativeIncrease,
        uint88[] calldata _increase
    ) external;

    /// @notice Edit the metadata of a task.
    /// @param _taskId Id of the task.
    /// @param _newMetadata New metadata of the task.
    /// @dev This metadata update might change the task completely. Show a warning to people who applied before the change.
    function editMetadata(uint256 _taskId, string calldata _newMetadata) external;

    /// @notice Transfers the manager role to a different address.
    /// @param _taskId Id of the task.
    /// @param _newManager What address should become the manager.
    function transferManagement(uint256 _taskId, address _newManager) external;

    /// @notice Completes the task through dispute resolution.
    /// @param _taskId Id of the task.
    /// @param _partialNativeReward How much of each native reward should be paid out.
    /// @param _partialReward How much of each ERC20 reward should be paid out.
    function completeByDispute(
        uint256 _taskId,
        uint96[] calldata _partialNativeReward,
        uint88[] calldata _partialReward
    ) external;

    /// @notice Releases a part of the reward to the executor without marking the task as complete.
    /// @param _taskId Id of the task.
    /// @param _partialNativeReward How much of each native reward should be paid out.
    /// @param _partialReward How much of each ERC20 reward should be paid out.
    /// @dev Will fetch balanceOf to set the budget afterwards, can be used in case funds where sent manually to the escrow to sync the budget.
    function partialPayment(uint256 _taskId, uint96[] calldata _partialNativeReward, uint88[] calldata _partialReward)
        external;
}
