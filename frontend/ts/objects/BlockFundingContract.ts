import { readContract } from "@wagmi/core";
import { parseAbiItem, decodeEventLog } from "viem";
import { getPublicClient } from "@wagmi/core";

import { callReadMethod } from "@/ts/wagmiWrapper";
import { contractAddress, blockFundingAbi, deployBlockNumber } from "@/ts/constants";

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
