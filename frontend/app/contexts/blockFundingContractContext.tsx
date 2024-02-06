import { createContext, useContext, useState, ReactNode } from "react";
import { useAccount } from "wagmi";

import { callReadMethod, callWriteMethod, watchEvent } from "@/app/ts/wagmiWrapper";
import { BlockFundingFunctions } from "@/app/ts/objects/BlockFundingContract";
import { Project } from "@/app/ts/objects/Project";
import { publicRead } from "@/app/ts/viemWrapper";

interface BlockFundingContractContextType {
  initBlockFundingContractContext: Function;
  projects: Project[];
  isLoadingProjects: boolean;
}

const BlockFundingContractContext = createContext<BlockFundingContractContextType | undefined>(undefined);
let initContractLock = false;

export const BlockFundingContractContextProvider = ({ children }: { children: ReactNode }) => {
  let { address } = useAccount();
  let [projects, setProjects] = useState([]);
  let [isLoadingProjects, setIsLoadingProjects] = useState(false);

  const initBlockFundingContractContext = async () => {
    // Ensure that we init only once (because takes time & don't want duplicate watchers)
    if (!initContractLock) {
      initContractLock = true;

      const results = await publicRead(BlockFundingFunctions.getProjects);
      console.log("Results = ");
      console.log(results);

      setProjects([]);
    }
  };

  const value = {
    initBlockFundingContractContext,
    projects,
    isLoadingProjects,
  };

  return <BlockFundingContractContext.Provider value={value}>{children}</BlockFundingContractContext.Provider>;
};

export const useBlockFundingContractContext = () => {
  const context = useContext(BlockFundingContractContext);
  if (context === undefined) {
    throw new Error("BlockFundingContractContext must be used within a BlockFundingContractContextProvider ");
  }
  return context;
};
