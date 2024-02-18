import { publicReadToBlockFundingProject } from "@/ts/viemWrapper";
import { Project } from "@/ts/objects/Project";
import { Vote } from "@/ts/objects/Vote";

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
  isProjectCanceledOrLastStepValidated = "isProjectCanceledOrLastStepValidated",
  isFinancer = "isFinancer",
  isWithdrawCurrentStepAvailable = "isWithdrawCurrentStepAvailable",
  isWithdrawEndProjectAvailable = "isWithdrawEndProjectAvailable",
  isWithdrawProjectNotFundedAvailable = "isWithdrawProjectNotFundedAvailable",
  isWithdrawProjectCanceledAvailable = "isWithdrawProjectCanceledAvailable",
}

export async function isWithdrawProjectCanceledAvailable(contractAddress: any, userAddress: any): Promise<boolean> {
  let ret: boolean = false;

  try {
    const data: any = await publicReadToBlockFundingProject(
      BlockFundingProjectFunctions.isWithdrawProjectCanceledAvailable,
      contractAddress,
      [],
      userAddress
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
}

export async function isWithdrawProjectNotFundedAvailable(contractAddress: any, userAddress: any): Promise<boolean> {
  let ret: boolean = false;

  try {
    const data: any = await publicReadToBlockFundingProject(
      BlockFundingProjectFunctions.isWithdrawProjectNotFundedAvailable,
      contractAddress,
      [],
      userAddress
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
}

export async function isWithdrawEndProjectAvailable(contractAddress: any, userAddress: any): Promise<boolean> {
  let ret: boolean = false;

  try {
    const data: any = await publicReadToBlockFundingProject(
      BlockFundingProjectFunctions.isWithdrawEndProjectAvailable,
      contractAddress,
      [],
      userAddress
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
}

export async function isWithdrawCurrentStepAvailable(contractAddress: any, userAddress: any): Promise<boolean> {
  let ret: boolean = false;

  try {
    const data: any = await publicReadToBlockFundingProject(
      BlockFundingProjectFunctions.isWithdrawCurrentStepAvailable,
      contractAddress,
      [],
      userAddress
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
}

export async function isFinancer(contractAddress: any, userAddress: any): Promise<boolean> {
  let ret: boolean = false;

  try {
    const data: any = await publicReadToBlockFundingProject(BlockFundingProjectFunctions.isFinancer, contractAddress, [], userAddress);
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
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

export async function isProjectCanceledOrLastStepValidated(contractAddress: any): Promise<boolean> {
  let ret: boolean = false;

  try {
    const data: any = await publicReadToBlockFundingProject(
      BlockFundingProjectFunctions.isProjectCanceledOrLastStepValidated,
      contractAddress
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
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

export async function getCurrentVote(contractAddress: any, userAddress: any): Promise<Vote> {
  let ret: Vote = Vote.createEmpty();

  try {
    const data: any = await publicReadToBlockFundingProject(BlockFundingProjectFunctions.getCurrentVote, contractAddress, [], userAddress);

    ret = new Vote(
      data.stepNumber,
      data.askedAmountToAddForStep,
      data.endVoteDate,
      data.hasVoteBeenValidated,
      data.isVoteRunning,
      data.voteType,
      data.hasFinancerVoted,
      data.votePowerInFavorOfProposal,
      data.votePowerAgainstProposal,
      data.totalVotePower
    );
  } catch (e) {
    console.log("Error :" + e);
  }

  return ret;
}

export async function getOldsEvents() {}
