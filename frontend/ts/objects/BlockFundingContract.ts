import { readContract } from "@wagmi/core";
import { contractAddress, blockFundingAbi } from "@/ts/constants";

export enum BlockFundingFunctions {
  getProjects = "getProjects",
  getProjectsAddresses = "getProjectsAddresses",
  createNewContract = "createNewProject",
}

export async function getProjects() {
  try {
    const data = await readContract({
      address: contractAddress,
      abi: blockFundingAbi,
      functionName: BlockFundingFunctions.getProjects.toString(),
      args: [],
    });
    console.log(data);
    return data;
  } catch (e) {}
}

export async function getOldsEvents() {}
