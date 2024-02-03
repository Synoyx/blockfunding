"use client";

import { useState, useEffect } from "react";
import { useAccount } from "wagmi";
import { Flex } from "@chakra-ui/react";

import Header from "@/app/components/struct/Header";
import Main from "@/app/components/struct/Main";
import Footer from "@/app/components/struct/Footer";
import Loader from "@/app/components/tools/Loader.jsx";
import NotConnected from "@/app/components/tools/NotConnected";

export default function Page() {
  let { isConnected, address } = useAccount();

  return (
    <Flex direction="column" height="100vh" justifyContent="space-between">
      <Header />
      <Flex grow="1" justifyContent="center">
        {isConnected ? <Main /> : <NotConnected />}
      </Flex>
      <Footer />
    </Flex>
  );
}
