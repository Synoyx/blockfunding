"use client";

import { useEffect } from "react";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";

export function ContextsLoader({ children }: any) {
  const { initBlockFundingContractContext } = useBlockFundingContractContext();

  console.log("Context loader");
  useEffect(() => {
    async function init() {
      console.log("Initializing ...");
      await initBlockFundingContractContext();
    }

    init();
  }, []);

  return <>{children}</>;
}
