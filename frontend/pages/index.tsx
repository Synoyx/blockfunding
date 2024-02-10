"use client";

import { Box } from "@chakra-ui/react";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import ProjectRow from "@/components/projectRow";

export default function HomePage() {
  const { projects, isLoadingProjects } = useBlockFundingContractContext();

  return (
    <Box marginTop="20px">
      <ProjectRow title="Derniers Projets" projects={projects} />
    </Box>
  );
}

//<ProjectRow title="Se Terminant Bientôt" projects={endingSoonProjects} />
//<ProjectRow title="Les Plus Financés" projects={mostFundedProjects} />
