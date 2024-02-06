import { Box } from "@chakra-ui/react";

import { useBlockFundingContractContext } from "@/app/contexts/blockFundingContractContext";
import ProjectRow from "@/app/components/projectRow";
import { Project } from "@/app/ts/objects/Project";

export const HomePage = () => {
  const { projects, isLoadingProjects } = useBlockFundingContractContext();

  return (
    <Box marginTop="20px">
      <ProjectRow title="Derniers Projets" projects={projects} />
    </Box>
  );
};

//<ProjectRow title="Se Terminant Bientôt" projects={endingSoonProjects} />
//<ProjectRow title="Les Plus Financés" projects={mostFundedProjects} />
