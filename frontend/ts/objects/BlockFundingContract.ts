import { readContract } from "@wagmi/core";
import { parseAbiItem, decodeEventLog } from "viem";
import { getPublicClient } from "@wagmi/core";

import { callReadMethod } from "@/ts/wagmiWrapper";
import { contractAddress, abi, deployBlockNumber } from "@/ts/constants";

export const enum BlockFundingFunctions {
  getProjects = "getProjects",
  createNewContract = "createNewProject",
}

export async function getProjects() {
  try {
    const data = await readContract({
      address: contractAddress,
      abi: abi,
      functionName: BlockFundingFunctions.getProjects.toString(),
      args: [],
    });
    console.log(data);
    return data;
  } catch (e) {}
}

export async function getOldsEvents() {}
