"use client";

import { useState, useEffect } from "react";
import { useAccount } from "wagmi";
import { Flex } from "@chakra-ui/react";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import Header from "@/components/struct/Header";
import Main from "@/pages/Main";
import Footer from "@/components/struct/Footer";

export default function Page() {
  const { initBlockFundingContractContext } = useBlockFundingContractContext();
  let { isConnected, address } = useAccount();

  useEffect(() => {
    async function init() {
      await initBlockFundingContractContext();
    }

    init();
  }, []);

  return (
    <Flex direction="column" height="100vh" justifyContent="space-between">
      <Header />
      <Flex grow="1" justifyContent="center">
        {isConnected ? <Main /> : <Main />}
      </Flex>
      <Footer />
    </Flex>
  );
}
