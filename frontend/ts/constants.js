export const NFT_STORAGE_TOKEN =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDU4MDY4N0Q0QjU4M0M4MDYyYjhGODcwNzQwRDg3MGQ5NUIwRGQ4NUIiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTcwNzQyODc3NjI0NywibmFtZSI6IlRlc3QifQ.MxIq9_MxyqECzJAzI_Jzpce-jJs_9Sm8vmE5DD9rRN0";

export const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
export const deployBlockNumber = 5433453n; //Put it as a bigint !
export const abi = [
  { type: "constructor", inputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "createNewContract",
    inputs: [
      { name: "_name_subtitle_description", type: "string[3]", internalType: "string[3]" },
      { name: "_mediasURI", type: "string[]", internalType: "string[]" },
      { name: "_campaignStartAndEndingDate_estimatedProjectReleaseDate_fundingRequested", type: "uint256[4]", internalType: "uint256[4]" },
      { name: "_targetWallet", type: "address", internalType: "address" },
      { name: "_projectCategory", type: "uint8", internalType: "enum BlockFunding.ProjectCategory" },
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
          { name: "owner", type: "address", internalType: "address" },
          { name: "totalFundsHarvested", type: "uint96", internalType: "uint96" },
          { name: "targetWallet", type: "address", internalType: "address" },
          { name: "fundingRequested", type: "uint96", internalType: "uint96" },
          { name: "campaignStartingDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "campaignEndingDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "estimatedProjectReleaseDateTimestamp", type: "uint32", internalType: "uint32" },
          { name: "hasBeenWithdrawn", type: "bool", internalType: "bool" },
          { name: "projectCategory", type: "uint8", internalType: "enum BlockFunding.ProjectCategory" },
          { name: "name", type: "string", internalType: "string" },
          { name: "subtitle", type: "string", internalType: "string" },
          { name: "description", type: "string", internalType: "string" },
          { name: "mediasURI", type: "string[]", internalType: "string[]" },
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
  {
    type: "event",
    name: "NewProjectHasBeenCreated",
    inputs: [{ name: "projectAddress", type: "address", indexed: false, internalType: "address" }],
    anonymous: false,
  },
  {
    type: "event",
    name: "OwnershipTransferred",
    inputs: [
      { name: "previousOwner", type: "address", indexed: true, internalType: "address" },
      { name: "newOwner", type: "address", indexed: true, internalType: "address" },
    ],
    anonymous: false,
  },
  { type: "error", name: "ERC1167FailedCreateClone", inputs: [] },
  { type: "error", name: "OwnableInvalidOwner", inputs: [{ name: "owner", type: "address", internalType: "address" }] },
  { type: "error", name: "OwnableUnauthorizedAccount", inputs: [{ name: "account", type: "address", internalType: "address" }] },
];
