import { publicReadToBlockFundingProject } from "@/ts/viemWrapper";
import { Project } from "@/ts/objects/Project";

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
  getData = "getData",
}

export async function getDonationAmount(contractAddress: any, financerAddress: any) {
  try {
    const data = await publicReadToBlockFundingProject(BlockFundingProjectFunctions.getFinancerDonationAmount, contractAddress, [
      financerAddress,
    ]);
    return data;
  } catch (e) {
    console.log("Error :" + e);
  }
}

export async function getProject(contractAddress: any): Promise<Project> {
  let ret: Project = Project.createEmpty();
  try {
    const data: any = await publicReadToBlockFundingProject(BlockFundingProjectFunctions.getData, contractAddress);

    let totalFundingRequested = 0;
    for (let projectStep of data.projectSteps) {
      totalFundingRequested += Number(projectStep.amountNeeded);
    }

    ret = new Project(
      contractAddress,
      data.campaignStartingDateTimestamp,
      data.campaignEndingDateTimestamp,
      data.estimatedProjectReleaseDateTimestamp,
      data.targetWallet,
      data.owner,
      data.totalFundsHarvested,
      data.projectCategory,
      data.name,
      data.subtitle,
      data.description,
      data.mediaURI,
      data.teamMembers,
      data.projectSteps
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
}

export async function getOldsEvents() {}
