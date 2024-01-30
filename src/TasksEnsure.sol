// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ITasks, Escrow} from "./ITasks.sol";

/*
  Functions to ensure a certain precondition is met.
*/
abstract contract TasksEnsure is ITasks {
    function _ensureTaskIsOpen(Task storage task) internal view {
        if (task.state != TaskState.Open) {
            revert TaskNotOpen();
        }
    }

    function _ensureTaskIsTaken(Task storage task) internal view {
        if (task.state != TaskState.Taken) {
            revert TaskNotTaken();
        }
    }

    function _ensureTaskNotClosed(Task storage task) internal view {
        if (task.state == TaskState.Closed) {
            revert TaskClosed();
        }
    }

    function _ensureSenderIsManager(Task storage task) internal view {
        if (msg.sender != task.manager) {
            revert NotManager();
        }
    }

    function _ensureSenderIsDisputeManager(Task storage task) internal view {
        if (msg.sender != task.disputeManager) {
            revert NotDisputeManager();
        }
    }

    /// @dev Should only be called if the task is not open!
    function _ensureSenderIsExecutor(Task storage task) internal view {
        if (msg.sender != task.applications[task.executorApplication].applicant) {
            revert NotExecutor();
        }
    }

    function _ensureRewardEndsWithNextToken(Reward[] memory reward) internal pure {
        unchecked {
            if (reward.length != 0 && !reward[reward.length - 1].nextToken) {
                revert RewardDoesntEndWithNextToken();
            }
        }
    }

    function _ensureApplicationExists(Task storage task, uint32 _applicationId) internal view {
        if (_applicationId >= task.applicationCount) {
            revert ApplicationDoesNotExist();
        }
    }

    function _ensureSenderIsApplicant(Application storage application) internal view {
        if (msg.sender != application.applicant) {
            revert NotYourApplication();
        }
    }

    function _ensureApplicationIsAccepted(Application storage application) internal view {
        if (!application.accepted) {
            revert ApplicationNotAccepted();
        }
    }

    function _ensureSubmissionExists(Task storage task, uint8 _submissionId) internal view {
        if (_submissionId >= task.submissionCount) {
            revert SubmissionDoesNotExist();
        }
    }

    function _ensureSubmissionNotJudged(Submission storage submission) internal view {
        if (submission.judgement != SubmissionJudgement.None) {
            revert SubmissionAlreadyJudged();
        }
    }

    function _ensureJudgementNotNone(SubmissionJudgement judgement) internal pure {
        if (judgement == SubmissionJudgement.None) {
            revert JudgementNone();
        }
    }

    function _ensureCancelTaskRequestExists(Task storage task, uint8 _requestId) internal view {
        if (_requestId >= task.cancelTaskRequestCount) {
            revert RequestDoesNotExist();
        }
    }

    function _ensureRequestNotAccepted(Request storage request) internal view {
        if (request.accepted) {
            revert RequestAlreadyAccepted();
        }
    }

    function _ensureRequestAccepted(Request storage request) internal view {
        if (!request.accepted) {
            revert RequestNotAccepted();
        }
    }

    function _ensureRequestNotExecuted(Request storage request) internal view {
        if (request.executed) {
            revert RequestAlreadyExecuted();
        }
    }

    function _toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert Overflow();
        }
        return uint8(value);
    }

    function _toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert Overflow();
        }
        return uint32(value);
    }

    function _toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert Overflow();
        }
        return uint96(value);
    }
}
