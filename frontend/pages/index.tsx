"use client";

import { Box } from "@chakra-ui/react";
import { useEffect } from "react";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import ProjectRow from "@/components/projectRow";
import { Project } from "@/ts/objects/Project";

export default function HomePage() {
  const { projects, isLoadingProjects, initBlockFundingContractContext } = useBlockFundingContractContext();

  useEffect(() => {
    async function init() {
      //await initBlockFundingContractContext();
    }

    init();
  }, []);

  return (
    <Box marginTop="20px">
      <ProjectRow title="Derniers Projets" projects={projects} />
    </Box>
  );
}

//<ProjectRow title="Se Terminant Bientôt" projects={endingSoonProjects} />
//<ProjectRow title="Les Plus Financés" projects={mostFundedProjects} />
