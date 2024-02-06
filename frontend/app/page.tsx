"use client";

import { useState, useEffect } from "react";
import { useAccount } from "wagmi";
import { Flex } from "@chakra-ui/react";

import { useBlockFundingContractContext } from "@/app/contexts/blockFundingContractContext";
import Header from "@/app/components/struct/Header";
import Main from "@/app/pages/Main";
import Footer from "@/app/components/struct/Footer";

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
