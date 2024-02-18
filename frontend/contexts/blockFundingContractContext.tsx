import { createContext, useContext, useState, ReactNode } from "react";
import { useAccount } from "wagmi";

import { callReadMethod, callWriteMethod, watchEvent } from "@/ts/wagmiWrapper";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { Project } from "@/ts/objects/Project";
import { publicReadToBlockFundingProject, publicReadToBlockFunding } from "@/ts/viemWrapper";
import { BlockFundingProjectFunctions } from "@/ts/objects/BlockFundingProjectContract";

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

      const projectsAddresses: any = await publicReadToBlockFunding(BlockFundingFunctions.getProjectsAddresses);
      for (let projectAddress of projectsAddresses) {
        const data: any = await publicReadToBlockFundingProject(BlockFundingProjectFunctions.getData, projectAddress);

        let totalFundingRequested = 0;
        for (let projectStep of data.projectSteps) {
          totalFundingRequested += Number(projectStep.amountNeeded);
        }

        projectsArray.push(
          new Project(
            projectAddress,
            data.campaignStartingDateTimestamp,
            data.campaignEndingDateTimestamp,
            data.estimatedProjectReleaseDateTimestamp,
            data.targetWallet,
            data.owner,
            data.totalFundsHarvested,
            data.projectCategory,
            data.name,
            data.subtitle,
            data.description,
            data.mediaURI,
            data.teamMembers,
            data.projectSteps
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
