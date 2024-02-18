import { http, createPublicClient } from "viem";
import { sepolia, localhost } from "viem/chains";

import { BlockFundingProjectFunctions } from "@/ts/objects/BlockFundingProjectContract";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { contractAddress, blockFundingAbi, blockFundingProjectAbi } from "@/ts/constants";

export async function publicReadToBlockFunding(functionToCall: BlockFundingFunctions) {
  const publicClient = createPublicClient({
    chain: process.env.NODE_ENV === "development" ? localhost : sepolia,
    transport: http(),
  });

  return await publicClient.readContract({
    address: contractAddress,
    abi: blockFundingAbi,
    functionName: functionToCall.valueOf(),
  });
}
export async function publicReadToBlockFundingProject(
  functionToCall: BlockFundingProjectFunctions,
  projectAddress: any,
  args: any = [],
  account: any = undefined
) {
  const publicClient = createPublicClient({
    chain: process.env.NODE_ENV === "development" ? localhost : sepolia,
    transport: http(),
  });

  if (account != undefined) {
    return await publicClient.readContract({
      address: projectAddress,
      abi: blockFundingProjectAbi,
      functionName: functionToCall.valueOf(),
      args: args,
      account: account,
    });
  } else {
    return await publicClient.readContract({
      address: projectAddress,
      abi: blockFundingProjectAbi,
      functionName: functionToCall.valueOf(),
      args: args,
    });
  }
}
