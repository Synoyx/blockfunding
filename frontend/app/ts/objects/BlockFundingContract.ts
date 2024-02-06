import { readContract } from "@wagmi/core";
import { parseAbiItem, decodeEventLog } from "viem";
import { getPublicClient } from "@wagmi/core";

import { callReadMethod } from "@/app/ts/wagmiWrapper";
import { contractAddress, abi, deployBlockNumber } from "@/app/ts/constants";

export const enum BlockFundingFunctions {
  getProjects = "getProjects",
  createNewContract = "createNewContract",
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

export async function getOldsEvents() {
  //TODO get passed events
}
