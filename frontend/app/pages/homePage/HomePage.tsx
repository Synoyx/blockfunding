import { Box, Heading, Link, SimpleGrid, Image, Button } from "@chakra-ui/react";
import NextLink from "next/link";

import ProjectCard from "@/app/components/projectCard";
import { Project } from "@/app/js/objects/Project.ts";

export const HomePage = () => {
  const latestProjects: Project[] = [
    new Project(1, "Project Alpha", "This is a brief subtitle of Project Alpha.", "/images/project-alpha.jpg"),
    new Project(2, "Project Beta", "An insightful subtitle for Project Beta.", "/images/project-beta.jpg"),
    new Project(3, "Project Gamma", "Discover the potential of Project Gamma.", "/images/project-gamma.jpg"),
    new Project(4, "Project Delta", "Exploring the horizons with Project Delta.", "/images/project-delta.jpg"),
    new Project(5, "Project Epsilon", "The future is now with Project Epsilon.", "/images/project-epsilon.jpg"),
  ];

  let endingSoonProjects: Project[] = latestProjects;
  let mostFundedProjects: Project[] = latestProjects;

  return (
    <Box textAlign="center" fontSize="xl">
      <Box p={5}>
        <Image src="/path-to-your-logo.png" alt="BlockFunding Logo" mx="auto" />
        <Heading>BlockFunding</Heading>
        <NextLink href="/login" passHref>
          <Button as={Link} mt={4} colorScheme="teal">
            Connexion
          </Button>
        </NextLink>
      </Box>

      <SimpleGrid columns={[1, null, 3]} spacing="40px" p={5}>
        <Box>
          <Heading as="h2" size="lg" mb={4}>
            Derniers Projets
          </Heading>
          {latestProjects.map((project: Project) => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </Box>

        <Box>
          <Heading as="h2" size="lg" mb={4}>
            Se Terminant Bientôt
          </Heading>
          {endingSoonProjects.map((project: Project) => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </Box>

        <Box>
          <Heading as="h2" size="lg" mb={4}>
            Les Plus Financés
          </Heading>
          {mostFundedProjects.map((project: Project) => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </Box>
      </SimpleGrid>
    </Box>
  );
};
