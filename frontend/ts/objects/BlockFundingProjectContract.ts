export const enum BlockFundingProjectFunctions {
  transferOwner = "transferOwner",
  withdrawCurrentStep = "withdrawCurrentStep",
  endProjectWithdraw = "endProjectWithdraw",
  projectNotFundedWithdraw = "projectNotFundedWithdraw",
  withdrawProjectCanceled = "withdrawProjectCanceled",
  fundProject = "fundProject", // Pass amount as value (payable method)
  askForMoreFunds = "askForMoreFunds", // Pass amount asked as parameter
  startVote = "startVote", // Pass vote type
  endVote = "endVote",
  sendVote = "sendVote", // Pass true or false (if you want the motion to be adopted)
  getFinancerDonationAmount = "getFinancerDonationAmount",
  addMessage = "addMessage", // Pass the IPFS CID as argument
  getCurrentVote = "getCurrentVote",
}
