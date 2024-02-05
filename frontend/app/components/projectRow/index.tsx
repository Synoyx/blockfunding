import { Box, Flex, Heading, IconButton, Text } from "@chakra-ui/react";
import { ChevronLeftIcon, ChevronRightIcon } from "@chakra-ui/icons";
import ProjectCard from "@/app/components/projectCard";
import { Project } from "@/app/js/objects/Project";
import { useRef } from "react";

interface ProjectRowProps {
  title: string;
  projects: Project[];
}

const ProjectRow = ({ title, projects }: ProjectRowProps) => {
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  const handleScroll = (direction: "left" | "right") => {
    if (scrollContainerRef.current) {
      const container = scrollContainerRef.current;
      const scrollAmount = container.offsetWidth / 2;
      const newScrollPosition = direction === "left" ? container.scrollLeft - scrollAmount : container.scrollLeft + scrollAmount;
      container.scrollTo({
        left: newScrollPosition,
        behavior: "smooth",
      });
    }
  };

  return (
    <Box my={8} marginTop="20px">
      <Text mb={4} fontSize="xl" fontWeight="bold">
        {title}
      </Text>
      <Flex justifyContent="space-between" alignItems="center" position="relative" overflow="hidden">
        <IconButton
          aria-label="Scroll left"
          icon={<ChevronLeftIcon />}
          onClick={() => handleScroll("left")}
          position="absolute"
          zIndex={2}
          left={0}
        />
        <Box
          ref={scrollContainerRef}
          overflowX="scroll"
          width="full"
          pb="16px"
          css={{
            "&::-webkit-scrollbar": {
              height: "8px",
            },
            "&::-webkit-scrollbar-track": {
              background: "rgba(0, 0, 0, 0.1)",
            },
            "&::-webkit-scrollbar-thumb": {
              background: "rgba(0, 0, 0, 0.2)",
              borderRadius: "4px",
            },
            scrollbarColor: "rgba(0, 0, 0, 0.2) rgba(0, 0, 0, 0.1)", // For Firefox
            scrollbarWidth: "thin", // For Firefox
          }}
        >
          <Flex>
            {projects.map((project, index) => (
              <ProjectCard key={index} project={project} />
            ))}
          </Flex>
        </Box>
        <IconButton
          aria-label="Scroll right"
          icon={<ChevronRightIcon />}
          onClick={() => handleScroll("right")}
          position="absolute"
          zIndex={2}
          right={0}
        />
      </Flex>
    </Box>
  );
};

export default ProjectRow;
