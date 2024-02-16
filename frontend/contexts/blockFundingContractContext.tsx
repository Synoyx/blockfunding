import { createContext, useContext, useState, ReactNode } from "react";
import { useAccount } from "wagmi";

import { callReadMethod, callWriteMethod, watchEvent } from "@/ts/wagmiWrapper";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { Project } from "@/ts/objects/Project";
import { publicRead } from "@/ts/viemWrapper";

interface BlockFundingContractContextType {
  initBlockFundingContractContext: Function;
  projects: Project[];
  isLoadingProjects: boolean;
}

const BlockFundingContractContext = createContext<BlockFundingContractContextType | undefined>(undefined);
let initContractLock = false;

export const BlockFundingContractContextProvider = ({ children }: { children: ReactNode }) => {
  let { address } = useAccount();
  let [projects, setProjects] = useState<Project[]>([]);
  let [isLoadingProjects, setIsLoadingProjects] = useState(false);

  const initBlockFundingContractContext = async () => {
    // Ensure that we init only once (because takes time & don't want duplicate watchers)
    if (!initContractLock) {
      initContractLock = true;

      let projectsArray: Project[] = [];

      const results: any = await publicRead(BlockFundingFunctions.getProjects);
      for (let res of results) {
        console.log("RESULT = ");
        console.log(res);
        let totalFundingRequested = 0;
        for (let projectStep of res.projectSteps) {
          totalFundingRequested += Number(projectStep.amountNeeded);
        }

        projectsArray.push(
          new Project(
            projectsArray.length,
            res.owner,
            res.name,
            res.subtitle,
            res.description,
            res.targetWallet,
            totalFundingRequested,
            res.totalFundsHarvested,
            res.campaignStartingDateTimestamp,
            res.campaignEndingDateTimestamp,
            res.estimatedProjectReleaseDateTimestamp,
            res.projectCategory,
            res.mediaURI
          )
        );
      }

      setProjects(projectsArray);
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
