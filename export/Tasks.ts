export const TasksContract = {
  address: "0xDdb23dacd41908C4eAE03982B1c6529252A56b62",
  abi: [
    { type: "constructor", inputs: [], stateMutability: "nonpayable" },
    {
      type: "function",
      name: "acceptApplications",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_applicationIds", type: "uint32[]", internalType: "uint32[]" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "acceptRequest",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        {
          name: "_requestType",
          type: "uint8",
          internalType: "enum ITasks.RequestType",
        },
        { name: "_requestId", type: "uint8", internalType: "uint8" },
        { name: "_execute", type: "bool", internalType: "bool" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "applyForTask",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_metadata", type: "string", internalType: "string" },
        {
          name: "_nativeReward",
          type: "tuple[]",
          internalType: "struct ITasks.NativeReward[]",
          components: [
            { name: "to", type: "address", internalType: "address" },
            { name: "amount", type: "uint96", internalType: "uint96" },
          ],
        },
        {
          name: "_reward",
          type: "tuple[]",
          internalType: "struct ITasks.Reward[]",
          components: [
            { name: "nextToken", type: "bool", internalType: "bool" },
            { name: "to", type: "address", internalType: "address" },
            { name: "amount", type: "uint88", internalType: "uint88" },
          ],
        },
      ],
      outputs: [
        { name: "applicationId", type: "uint32", internalType: "uint32" },
      ],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "cancelTask",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_metadata", type: "string", internalType: "string" },
      ],
      outputs: [
        { name: "cancelTaskRequestId", type: "uint8", internalType: "uint8" },
      ],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "completeByDispute",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        {
          name: "_partialNativeReward",
          type: "uint96[]",
          internalType: "uint96[]",
        },
        { name: "_partialReward", type: "uint88[]", internalType: "uint88[]" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "createSubmission",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_metadata", type: "string", internalType: "string" },
      ],
      outputs: [{ name: "submissionId", type: "uint8", internalType: "uint8" }],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "createTask",
      inputs: [
        { name: "_metadata", type: "string", internalType: "string" },
        { name: "_deadline", type: "uint64", internalType: "uint64" },
        { name: "_manager", type: "address", internalType: "address" },
        { name: "_disputeManager", type: "address", internalType: "address" },
        {
          name: "_budget",
          type: "tuple[]",
          internalType: "struct ITasks.ERC20Transfer[]",
          components: [
            {
              name: "tokenContract",
              type: "address",
              internalType: "contract IERC20",
            },
            { name: "amount", type: "uint96", internalType: "uint96" },
          ],
        },
        {
          name: "_preapprove",
          type: "tuple[]",
          internalType: "struct ITasks.PreapprovedApplication[]",
          components: [
            { name: "applicant", type: "address", internalType: "address" },
            {
              name: "nativeReward",
              type: "tuple[]",
              internalType: "struct ITasks.NativeReward[]",
              components: [
                { name: "to", type: "address", internalType: "address" },
                { name: "amount", type: "uint96", internalType: "uint96" },
              ],
            },
            {
              name: "reward",
              type: "tuple[]",
              internalType: "struct ITasks.Reward[]",
              components: [
                { name: "nextToken", type: "bool", internalType: "bool" },
                { name: "to", type: "address", internalType: "address" },
                { name: "amount", type: "uint88", internalType: "uint88" },
              ],
            },
          ],
        },
      ],
      outputs: [{ name: "taskId", type: "uint256", internalType: "uint256" }],
      stateMutability: "payable",
    },
    {
      type: "function",
      name: "editMetadata",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_newMetadata", type: "string", internalType: "string" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "executeRequest",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        {
          name: "_requestType",
          type: "uint8",
          internalType: "enum ITasks.RequestType",
        },
        { name: "_requestId", type: "uint8", internalType: "uint8" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "extendDeadline",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_extension", type: "uint64", internalType: "uint64" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "getTask",
      inputs: [{ name: "_taskId", type: "uint256", internalType: "uint256" }],
      outputs: [
        {
          name: "offchainTask",
          type: "tuple",
          internalType: "struct ITasks.OffChainTask",
          components: [
            { name: "metadata", type: "string", internalType: "string" },
            { name: "deadline", type: "uint64", internalType: "uint64" },
            {
              name: "executorApplication",
              type: "uint32",
              internalType: "uint32",
            },
            { name: "manager", type: "address", internalType: "address" },
            {
              name: "disputeManager",
              type: "address",
              internalType: "address",
            },
            { name: "creator", type: "address", internalType: "address" },
            {
              name: "state",
              type: "uint8",
              internalType: "enum ITasks.TaskState",
            },
            {
              name: "escrow",
              type: "address",
              internalType: "contract Escrow",
            },
            { name: "nativeBudget", type: "uint96", internalType: "uint96" },
            {
              name: "budget",
              type: "tuple[]",
              internalType: "struct ITasks.ERC20Transfer[]",
              components: [
                {
                  name: "tokenContract",
                  type: "address",
                  internalType: "contract IERC20",
                },
                { name: "amount", type: "uint96", internalType: "uint96" },
              ],
            },
            {
              name: "applications",
              type: "tuple[]",
              internalType: "struct ITasks.OffChainApplication[]",
              components: [
                { name: "metadata", type: "string", internalType: "string" },
                { name: "applicant", type: "address", internalType: "address" },
                { name: "accepted", type: "bool", internalType: "bool" },
                {
                  name: "nativeReward",
                  type: "tuple[]",
                  internalType: "struct ITasks.NativeReward[]",
                  components: [
                    { name: "to", type: "address", internalType: "address" },
                    { name: "amount", type: "uint96", internalType: "uint96" },
                  ],
                },
                {
                  name: "reward",
                  type: "tuple[]",
                  internalType: "struct ITasks.Reward[]",
                  components: [
                    { name: "nextToken", type: "bool", internalType: "bool" },
                    { name: "to", type: "address", internalType: "address" },
                    { name: "amount", type: "uint88", internalType: "uint88" },
                  ],
                },
              ],
            },
            {
              name: "submissions",
              type: "tuple[]",
              internalType: "struct ITasks.Submission[]",
              components: [
                { name: "metadata", type: "string", internalType: "string" },
                { name: "feedback", type: "string", internalType: "string" },
                {
                  name: "judgement",
                  type: "uint8",
                  internalType: "enum ITasks.SubmissionJudgement",
                },
              ],
            },
            {
              name: "cancelTaskRequests",
              type: "tuple[]",
              internalType: "struct ITasks.CancelTaskRequest[]",
              components: [
                {
                  name: "request",
                  type: "tuple",
                  internalType: "struct ITasks.Request",
                  components: [
                    { name: "accepted", type: "bool", internalType: "bool" },
                    { name: "executed", type: "bool", internalType: "bool" },
                  ],
                },
                { name: "metadata", type: "string", internalType: "string" },
              ],
            },
          ],
        },
      ],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "getTasks",
      inputs: [
        { name: "_taskIds", type: "uint256[]", internalType: "uint256[]" },
      ],
      outputs: [
        {
          name: "",
          type: "tuple[]",
          internalType: "struct ITasks.OffChainTask[]",
          components: [
            { name: "metadata", type: "string", internalType: "string" },
            { name: "deadline", type: "uint64", internalType: "uint64" },
            {
              name: "executorApplication",
              type: "uint32",
              internalType: "uint32",
            },
            { name: "manager", type: "address", internalType: "address" },
            {
              name: "disputeManager",
              type: "address",
              internalType: "address",
            },
            { name: "creator", type: "address", internalType: "address" },
            {
              name: "state",
              type: "uint8",
              internalType: "enum ITasks.TaskState",
            },
            {
              name: "escrow",
              type: "address",
              internalType: "contract Escrow",
            },
            { name: "nativeBudget", type: "uint96", internalType: "uint96" },
            {
              name: "budget",
              type: "tuple[]",
              internalType: "struct ITasks.ERC20Transfer[]",
              components: [
                {
                  name: "tokenContract",
                  type: "address",
                  internalType: "contract IERC20",
                },
                { name: "amount", type: "uint96", internalType: "uint96" },
              ],
            },
            {
              name: "applications",
              type: "tuple[]",
              internalType: "struct ITasks.OffChainApplication[]",
              components: [
                { name: "metadata", type: "string", internalType: "string" },
                { name: "applicant", type: "address", internalType: "address" },
                { name: "accepted", type: "bool", internalType: "bool" },
                {
                  name: "nativeReward",
                  type: "tuple[]",
                  internalType: "struct ITasks.NativeReward[]",
                  components: [
                    { name: "to", type: "address", internalType: "address" },
                    { name: "amount", type: "uint96", internalType: "uint96" },
                  ],
                },
                {
                  name: "reward",
                  type: "tuple[]",
                  internalType: "struct ITasks.Reward[]",
                  components: [
                    { name: "nextToken", type: "bool", internalType: "bool" },
                    { name: "to", type: "address", internalType: "address" },
                    { name: "amount", type: "uint88", internalType: "uint88" },
                  ],
                },
              ],
            },
            {
              name: "submissions",
              type: "tuple[]",
              internalType: "struct ITasks.Submission[]",
              components: [
                { name: "metadata", type: "string", internalType: "string" },
                { name: "feedback", type: "string", internalType: "string" },
                {
                  name: "judgement",
                  type: "uint8",
                  internalType: "enum ITasks.SubmissionJudgement",
                },
              ],
            },
            {
              name: "cancelTaskRequests",
              type: "tuple[]",
              internalType: "struct ITasks.CancelTaskRequest[]",
              components: [
                {
                  name: "request",
                  type: "tuple",
                  internalType: "struct ITasks.Request",
                  components: [
                    { name: "accepted", type: "bool", internalType: "bool" },
                    { name: "executed", type: "bool", internalType: "bool" },
                  ],
                },
                { name: "metadata", type: "string", internalType: "string" },
              ],
            },
          ],
        },
      ],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "increaseBudget",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_increase", type: "uint96[]", internalType: "uint96[]" },
      ],
      outputs: [],
      stateMutability: "payable",
    },
    {
      type: "function",
      name: "increaseReward",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_applicationId", type: "uint32", internalType: "uint32" },
        { name: "_nativeIncrease", type: "uint96[]", internalType: "uint96[]" },
        { name: "_increase", type: "uint88[]", internalType: "uint88[]" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "owner",
      inputs: [],
      outputs: [{ name: "", type: "address", internalType: "address" }],
      stateMutability: "pure",
    },
    {
      type: "function",
      name: "partialPayment",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        {
          name: "_partialNativeReward",
          type: "uint96[]",
          internalType: "uint96[]",
        },
        { name: "_partialReward", type: "uint88[]", internalType: "uint88[]" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "rescue",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "token", type: "address", internalType: "contract IERC20" },
        { name: "to", type: "address", internalType: "address" },
        { name: "amount", type: "uint256", internalType: "uint256" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "rescueNative",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "to", type: "address", internalType: "address payable" },
        { name: "amount", type: "uint256", internalType: "uint256" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "reviewSubmission",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_submissionId", type: "uint8", internalType: "uint8" },
        {
          name: "_judgement",
          type: "uint8",
          internalType: "enum ITasks.SubmissionJudgement",
        },
        { name: "_feedback", type: "string", internalType: "string" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "takeTask",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_applicationId", type: "uint32", internalType: "uint32" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "taskCount",
      inputs: [],
      outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "transferManagement",
      inputs: [
        { name: "_taskId", type: "uint256", internalType: "uint256" },
        { name: "_newManager", type: "address", internalType: "address" },
      ],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "event",
      name: "ApplicationAccepted",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "applicationId",
          type: "uint32",
          indexed: true,
          internalType: "uint32",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "ApplicationCreated",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "applicationId",
          type: "uint32",
          indexed: true,
          internalType: "uint32",
        },
        {
          name: "metadata",
          type: "string",
          indexed: false,
          internalType: "string",
        },
        {
          name: "applicant",
          type: "address",
          indexed: false,
          internalType: "address",
        },
        {
          name: "nativeReward",
          type: "tuple[]",
          indexed: false,
          internalType: "struct ITasks.NativeReward[]",
          components: [
            { name: "to", type: "address", internalType: "address" },
            { name: "amount", type: "uint96", internalType: "uint96" },
          ],
        },
        {
          name: "reward",
          type: "tuple[]",
          indexed: false,
          internalType: "struct ITasks.Reward[]",
          components: [
            { name: "nextToken", type: "bool", internalType: "bool" },
            { name: "to", type: "address", internalType: "address" },
            { name: "amount", type: "uint88", internalType: "uint88" },
          ],
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "BudgetChanged",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "CancelTaskRequested",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "requestId",
          type: "uint8",
          indexed: true,
          internalType: "uint8",
        },
        {
          name: "metadata",
          type: "string",
          indexed: false,
          internalType: "string",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "DeadlineChanged",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "newDeadline",
          type: "uint64",
          indexed: false,
          internalType: "uint64",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "ManagerChanged",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "newManager",
          type: "address",
          indexed: false,
          internalType: "address",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "MetadataChanged",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "newMetadata",
          type: "string",
          indexed: false,
          internalType: "string",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "PartialPayment",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "partialNativeReward",
          type: "uint96[]",
          indexed: false,
          internalType: "uint96[]",
        },
        {
          name: "partialReward",
          type: "uint88[]",
          indexed: false,
          internalType: "uint88[]",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "RequestAccepted",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "requestType",
          type: "uint8",
          indexed: true,
          internalType: "enum ITasks.RequestType",
        },
        {
          name: "requestId",
          type: "uint8",
          indexed: true,
          internalType: "uint8",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "RequestExecuted",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "requestType",
          type: "uint8",
          indexed: true,
          internalType: "enum ITasks.RequestType",
        },
        {
          name: "requestId",
          type: "uint8",
          indexed: true,
          internalType: "uint8",
        },
        {
          name: "by",
          type: "address",
          indexed: false,
          internalType: "address",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "RewardIncreased",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "applicationId",
          type: "uint32",
          indexed: true,
          internalType: "uint32",
        },
        {
          name: "nativeIncrease",
          type: "uint96[]",
          indexed: false,
          internalType: "uint96[]",
        },
        {
          name: "increase",
          type: "uint88[]",
          indexed: false,
          internalType: "uint88[]",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "SubmissionCreated",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "submissionId",
          type: "uint8",
          indexed: true,
          internalType: "uint8",
        },
        {
          name: "metadata",
          type: "string",
          indexed: false,
          internalType: "string",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "SubmissionReviewed",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "submissionId",
          type: "uint8",
          indexed: true,
          internalType: "uint8",
        },
        {
          name: "judgement",
          type: "uint8",
          indexed: false,
          internalType: "enum ITasks.SubmissionJudgement",
        },
        {
          name: "feedback",
          type: "string",
          indexed: false,
          internalType: "string",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "TaskCancelled",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "metadata",
          type: "string",
          indexed: false,
          internalType: "string",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "TaskCompleted",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "source",
          type: "uint8",
          indexed: false,
          internalType: "enum ITasks.TaskCompletionSource",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "TaskCreated",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "metadata",
          type: "string",
          indexed: false,
          internalType: "string",
        },
        {
          name: "deadline",
          type: "uint64",
          indexed: false,
          internalType: "uint64",
        },
        {
          name: "manager",
          type: "address",
          indexed: false,
          internalType: "address",
        },
        {
          name: "disputeManager",
          type: "address",
          indexed: false,
          internalType: "address",
        },
        {
          name: "creator",
          type: "address",
          indexed: false,
          internalType: "address",
        },
        {
          name: "nativeBudget",
          type: "uint96",
          indexed: false,
          internalType: "uint96",
        },
        {
          name: "budget",
          type: "tuple[]",
          indexed: false,
          internalType: "struct ITasks.ERC20Transfer[]",
          components: [
            {
              name: "tokenContract",
              type: "address",
              internalType: "contract IERC20",
            },
            { name: "amount", type: "uint96", internalType: "uint96" },
          ],
        },
        {
          name: "escrow",
          type: "address",
          indexed: false,
          internalType: "contract Escrow",
        },
      ],
      anonymous: false,
    },
    {
      type: "event",
      name: "TaskTaken",
      inputs: [
        {
          name: "taskId",
          type: "uint256",
          indexed: true,
          internalType: "uint256",
        },
        {
          name: "applicationId",
          type: "uint32",
          indexed: true,
          internalType: "uint32",
        },
      ],
      anonymous: false,
    },
    {
      type: "error",
      name: "AddressEmptyCode",
      inputs: [{ name: "target", type: "address", internalType: "address" }],
    },
    {
      type: "error",
      name: "AddressInsufficientBalance",
      inputs: [{ name: "account", type: "address", internalType: "address" }],
    },
    { type: "error", name: "ApplicationDoesNotExist", inputs: [] },
    { type: "error", name: "ApplicationNotAccepted", inputs: [] },
    { type: "error", name: "ERC1167FailedCreateClone", inputs: [] },
    { type: "error", name: "FailedInnerCall", inputs: [] },
    { type: "error", name: "JudgementNone", inputs: [] },
    { type: "error", name: "ManualBudgetIncreaseNeeded", inputs: [] },
    { type: "error", name: "NativeTransferFailed", inputs: [] },
    { type: "error", name: "NotDisputeManager", inputs: [] },
    { type: "error", name: "NotEnoughNativeCurrencyAttached", inputs: [] },
    { type: "error", name: "NotExecutor", inputs: [] },
    { type: "error", name: "NotManager", inputs: [] },
    { type: "error", name: "NotYourApplication", inputs: [] },
    { type: "error", name: "Overflow", inputs: [] },
    { type: "error", name: "PartialRewardAboveFullReward", inputs: [] },
    { type: "error", name: "RequestAlreadyAccepted", inputs: [] },
    { type: "error", name: "RequestAlreadyExecuted", inputs: [] },
    { type: "error", name: "RequestDoesNotExist", inputs: [] },
    { type: "error", name: "RequestNotAccepted", inputs: [] },
    { type: "error", name: "RewardAboveBudget", inputs: [] },
    { type: "error", name: "RewardDoesntEndWithNextToken", inputs: [] },
    {
      type: "error",
      name: "SafeERC20FailedOperation",
      inputs: [{ name: "token", type: "address", internalType: "address" }],
    },
    { type: "error", name: "SubmissionAlreadyJudged", inputs: [] },
    { type: "error", name: "SubmissionDoesNotExist", inputs: [] },
    { type: "error", name: "TaskClosed", inputs: [] },
    { type: "error", name: "TaskDoesNotExist", inputs: [] },
    { type: "error", name: "TaskNotClosed", inputs: [] },
    { type: "error", name: "TaskNotOpen", inputs: [] },
    { type: "error", name: "TaskNotTaken", inputs: [] },
  ],
} as const;
