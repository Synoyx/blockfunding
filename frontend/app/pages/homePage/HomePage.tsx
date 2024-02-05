import { ChevronLeftIcon, ChevronRightIcon } from "@chakra-ui/icons";
import { Flex, Box, Heading, Text, IconButton, useBreakpointValue } from "@chakra-ui/react";
import { useRef } from "react";

import ProjectRow from "@/app/components/projectRow";
import { Project } from "@/app/js/objects/Project";

export const HomePage = () => {
  const latestProjects: Project[] = [
    new Project(
      1,
      "Project Alphatrzetrzetreztrze",
      "This is a brief subtitle of Project Alpha.trzetrzetreztreztrez",
      "/images/project-alpha.jpg"
    ),
    new Project(2, "Project Beta", "An insightful subtitle for Project Beta.", "/images/project-beta.jpg"),
    new Project(3, "Project Gamma", "Discover the potential of Project Gamma.", "/images/project-gamma.jpg"),
    new Project(4, "Project Delta", "Exploring the horizons with Project Delta.", "/images/project-delta.jpg"),
    new Project(5, "Project Epsilon", "The future is now with Project Epsilon.", "/images/project-epsilon.jpg"),
    new Project(6, "Project Gamma", "Discover the potential of Project Gamma.", "/images/project-gamma.jpg"),
    new Project(7, "Project Delta", "Exploring the horizons with Project Delta.", "/images/project-delta.jpg"),
    new Project(8, "Project Epsilon", "The future is now with Project Epsilon.", "/images/project-epsilon.jpg"),
  ];

  let endingSoonProjects: Project[] = latestProjects;
  let mostFundedProjects: Project[] = latestProjects;

  return (
    <Box marginTop="20px">
      <ProjectRow title="Derniers Projets" projects={latestProjects} />
      <ProjectRow title="Se Terminant Bientôt" projects={endingSoonProjects} />
      <ProjectRow title="Les Plus Financés" projects={mostFundedProjects} />
    </Box>
  );
};
