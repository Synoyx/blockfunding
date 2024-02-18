"use client";

import { useEffect } from "react";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";

export function ContextsLoader({ children }: any) {
  const { initBlockFundingContractContext } = useBlockFundingContractContext();

  useEffect(() => {
    async function init() {
      await initBlockFundingContractContext();
    }

    init();
  }, []);

  return <>{children}</>;
}
