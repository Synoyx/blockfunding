import { http, createPublicClient, stringify } from "viem";
import { sepolia } from "viem/chains";

import { contractAddress, abi } from "@/js/constants";
import { VotingFunctions } from "@/js/wagmiWrapper.js";

import { Flex, Heading, Text, Spinner } from "@chakra-ui/react";
import { useEffect, useState } from "react";

const NotConnected = () => {
  async function init() {
    const publicClient = createPublicClient({
      chain: sepolia,
      transport: http(),
    });

    /*
    const gatheredStatus = await publicClient.readContract({
      address: contractAddress,
      abi: abi,
      functionName: VotingFunctions.workflowStatus,
    });
    */
  }

  useEffect(() => {
    init();
  }, []);

  return (
    <Flex direction="column" justifyContent="center" alignItems="center" height="80vh">
      <Heading fontSize="4xl">Hi there !</Heading>
      <Heading fontSize="2xl" mt="4">
        Welcome to BlockFunding
      </Heading>
      <Text mt="2rem">Please connect your wallet to be able to interact with all functionnalities of my DApp !</Text>
    </Flex>
  );
};

export default NotConnected;
