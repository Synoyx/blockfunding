import { Box, Image, Text, useColorModeValue, VStack } from "@chakra-ui/react";
import Link from "next/link";

import { Project } from "@/ts/objects/Project";

interface ProjectCardProps {
  project: Project;
}

const ProjectCard: React.FC<ProjectCardProps> = ({ project }) => {
  const bgColor = useColorModeValue("white", "gray.800"); // Gère le thème clair/sombre
  const borderColor = useColorModeValue("gray.200", "gray.700");

  return (
    <Link
      href={{
        pathname: "/ProjectDetails",
        query: { id: project.name },
      }}
    >
      <Box
        borderWidth="1px"
        borderRadius="lg"
        overflow="hidden"
        p={4}
        bg={bgColor}
        borderColor={borderColor}
        boxShadow="md"
        m={2} // Margin pour espacer les cartes
        width="200px"
        maxWidth="200px" // Largeur fixe pour toutes les cartes
        flexGrow={0} // Empêche la carte de grandir
        flexShrink={0} // Empêche la carte de rétrécir
      >
        <Image src={project.mediaURI} alt={project.name} borderRadius="lg" objectFit="cover" width="100%" height="200px" />
        <VStack spacing={2} align="start" mt={4}>
          <Text fontSize="xl" fontWeight="bold" noOfLines={1}>
            {project.name}
          </Text>
          <Text fontSize="md" color="gray.500" noOfLines={2}>
            {project.subtitle}
          </Text>
        </VStack>
      </Box>
    </Link>
  );
};

export default ProjectCard;
