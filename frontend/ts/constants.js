export const NFT_STORAGE_TOKEN =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDU4MDY4N0Q0QjU4M0M4MDYyYjhGODcwNzQwRDg3MGQ5NUIwRGQ4NUIiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTcwNzQyODc3NjI0NywibmFtZSI6IlRlc3QifQ.MxIq9_MxyqECzJAzI_Jzpce-jJs_9Sm8vmE5DD9rRN0";

export const contractAddress = "0x9a9f2ccfde556a7e9ff0848998aa4a0cfd8863ae";
export const deployBlockNumber = 5433453n; //Put it as a bigint !
export const abi = [
  { type: "constructor", inputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "createNewProject",
    inputs: [
      {
        name: "_data",
        type: "tuple",
        internalType: "struct BlockFundingProject.ProjectData",
        components: [
          { name: "campaignStartingDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "campaignEndingDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "estimatedProjectReleaseDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "targetWallet", type: "address", internalType: "address" },
          { name: "owner", type: "address", internalType: "address" },
          { name: "totalFundsHarvested", type: "uint96", internalType: "uint96" },
          { name: "projectCategory", type: "uint8", internalType: "enum BlockFunding.ProjectCategory" },
          { name: "name", type: "string", internalType: "string" },
          { name: "subtitle", type: "string", internalType: "string" },
          { name: "description", type: "string", internalType: "string" },
          { name: "mediaURI", type: "string", internalType: "string" },
          {
            name: "teamMembers",
            type: "tuple[]",
            internalType: "struct BlockFundingProject.TeamMember[]",
            components: [
              { name: "firstName", type: "string", internalType: "string" },
              { name: "lastName", type: "string", internalType: "string" },
              { name: "description", type: "string", internalType: "string" },
              { name: "photoLink", type: "string", internalType: "string" },
              { name: "role", type: "string", internalType: "string" },
              { name: "walletAddress", type: "address", internalType: "address" },
            ],
          },
          {
            name: "projectSteps",
            type: "tuple[]",
            internalType: "struct BlockFundingProject.ProjectStep[]",
            components: [
              { name: "name", type: "string", internalType: "string" },
              { name: "description", type: "string", internalType: "string" },
              { name: "amountNeeded", type: "uint96", internalType: "uint96" },
              { name: "amountFunded", type: "uint96", internalType: "uint96" },
              { name: "isFunded", type: "bool", internalType: "bool" },
              { name: "orderNumber", type: "uint8", internalType: "uint8" },
              { name: "hasBeenValidated", type: "bool", internalType: "bool" },
            ],
          },
        ],
      },
    ],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "getProjects",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "tuple[]",
        internalType: "struct BlockFundingProject.ProjectData[]",
        components: [
          { name: "campaignStartingDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "campaignEndingDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "estimatedProjectReleaseDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "targetWallet", type: "address", internalType: "address" },
          { name: "owner", type: "address", internalType: "address" },
          { name: "totalFundsHarvested", type: "uint96", internalType: "uint96" },
          { name: "projectCategory", type: "uint8", internalType: "enum BlockFunding.ProjectCategory" },
          { name: "name", type: "string", internalType: "string" },
          { name: "subtitle", type: "string", internalType: "string" },
          { name: "description", type: "string", internalType: "string" },
          { name: "mediaURI", type: "string", internalType: "string" },
          {
            name: "teamMembers",
            type: "tuple[]",
            internalType: "struct BlockFundingProject.TeamMember[]",
            components: [
              { name: "firstName", type: "string", internalType: "string" },
              { name: "lastName", type: "string", internalType: "string" },
              { name: "description", type: "string", internalType: "string" },
              { name: "photoLink", type: "string", internalType: "string" },
              { name: "role", type: "string", internalType: "string" },
              { name: "walletAddress", type: "address", internalType: "address" },
            ],
          },
          {
            name: "projectSteps",
            type: "tuple[]",
            internalType: "struct BlockFundingProject.ProjectStep[]",
            components: [
              { name: "name", type: "string", internalType: "string" },
              { name: "description", type: "string", internalType: "string" },
              { name: "amountNeeded", type: "uint96", internalType: "uint96" },
              { name: "amountFunded", type: "uint96", internalType: "uint96" },
              { name: "isFunded", type: "bool", internalType: "bool" },
              { name: "orderNumber", type: "uint8", internalType: "uint8" },
              { name: "hasBeenValidated", type: "bool", internalType: "bool" },
            ],
          },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getProjectsAddresses",
    inputs: [],
    outputs: [{ name: "", type: "address[]", internalType: "address[]" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owner",
    inputs: [],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "projects",
    inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  { type: "function", name: "renounceOwnership", inputs: [], outputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "transferOwnership",
    inputs: [{ name: "newOwner", type: "address", internalType: "address" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  { type: "event", name: "NewProjectHasBeenCreated", inputs: [], anonymous: false },
  {
    type: "event",
    name: "OwnershipTransferred",
    inputs: [
      { name: "previousOwner", type: "address", indexed: true, internalType: "address" },
      { name: "newOwner", type: "address", indexed: true, internalType: "address" },
    ],
    anonymous: false,
  },
  { type: "error", name: "AProjectIsAlreadyLiveFromThisOwner", inputs: [] },
  { type: "error", name: "ERC1167FailedCreateClone", inputs: [] },
  { type: "error", name: "OwnableInvalidOwner", inputs: [{ name: "owner", type: "address", internalType: "address" }] },
  { type: "error", name: "OwnableUnauthorizedAccount", inputs: [{ name: "account", type: "address", internalType: "address" }] },
];
