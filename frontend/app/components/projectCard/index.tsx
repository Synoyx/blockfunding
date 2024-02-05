import { Box, Image, Text, Badge } from "@chakra-ui/react";

const ProjectCard = ({ project }: any) => {
  return (
    <Box maxW="sm" borderWidth="1px" borderRadius="lg" overflow="hidden" p={5}>
      <Image src={project.image} alt={`Image de ${project.name}`} />
      <Box p="6">
        <Box display="flex" alignItems="baseline">
          <Badge borderRadius="full" px="2" colorScheme="teal">
            Nouveau
          </Badge>
          <Box color="gray.500" fontWeight="semibold" letterSpacing="wide" fontSize="xs" textTransform="uppercase" ml="2">
            {project.subtitle}
          </Box>
        </Box>
        <Box mt="1" fontWeight="semibold" as="h4" lineHeight="tight" isTruncated>
          {project.name}
        </Box>
      </Box>
    </Box>
  );
};

export default ProjectCard;
