import { http, createPublicClient } from "viem";
import { sepolia, localhost } from "viem/chains";

import { BlockFundingProjectFunctions } from "@/app/ts/objects/BlockFundingProjectContract";
import { BlockFundingFunctions } from "@/app/ts/objects/BlockFundingContract";
import { contractAddress, abi } from "@/app/ts/constants";

export async function publicRead(functionToCall: BlockFundingFunctions | BlockFundingProjectFunctions) {
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
