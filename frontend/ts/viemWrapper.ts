import { http, createPublicClient } from "viem";
import { sepolia, localhost } from "viem/chains";

import { BlockFundingProjectFunctions } from "@/ts/objects/BlockFundingProjectContract";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { contractAddress, abi } from "@/ts/constants";

//export async function publicRead(functionToCall: BlockFundingFunctions | BlockFundingProjectFunctions) {
export async function publicRead(functionToCall: BlockFundingFunctions) {
  const publicClient = createPublicClient({
    chain: localhost,
    transport: http(),
  });

  return await publicClient.readContract({
    address: contractAddress,
    abi: abi,
    functionName: functionToCall.valueOf(),
  });
}
