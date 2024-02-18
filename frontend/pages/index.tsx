"use client";

import { Box, Button, Text, Flex, Select, Image } from "@chakra-ui/react";
import "react-responsive-carousel/lib/styles/carousel.min.css";
import { Carousel } from "react-responsive-carousel";
import { useEffect } from "react";
import Link from "next/link";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import Loader from "@/components/tools/Loader";
import { Project, ProjectCategory } from "@/ts/objects/Project";

export default function HomePage() {
  const { projects, isLoadingProjects } = useBlockFundingContractContext();

  useEffect(() => {
    document.title = "Accueil";
  });

  return (
    <Flex as="main" width="100%" flexDirection="column" p="20px" justifyContent="space-evenly">
      {isLoadingProjects ? (
        <Loader />
      ) : (
        <>
          <LastProjectsSection projects={projects} />
          <MoreProjectsSection
            projects={projects}
            categories={Object.keys(ProjectCategory)}
            selectedCategory={"Art"}
          />
        </>
      )}
    </Flex>
  );
}

interface LastProjectsSectionProps {
  projects: Project[];
}

const LastProjectsSection = ({ projects }: LastProjectsSectionProps) => {
  return (
    <Box>
      <Flex justifyContent="space-between" alignItems="center" mb="15px">
        <Text fontSize="2xl">Most popular projects</Text>
        <Link href="/CreateProject">
          <Button bg="green.500" color="white">
            Create project
          </Button>
        </Link>
      </Flex>
      <Carousel
        showArrows={true}
        autoPlay={true}
        infiniteLoop={true}
        showThumbs={false}
        showStatus={false}
        showIndicators={true}
        dynamicHeight={false}
        emulateTouch={true}
      >
        {projects.map((project: Project, index: number) => (
          <Link
            href={{
              pathname: "/ProjectDetails",
              query: { id: project.name },
            }}
          >
            <Box key={index}>
              <Box position="relative" width="100%" height="500px">
                <Image src={project.mediaURI} alt={project.name} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                <Box position="absolute" bottom="50px" left="0" background="rgba(0, 0, 0, 0.5)" color="white" width="100%" p="10px">
                  <Text fontWeight="bold" fontSize="lg" whiteSpace="nowrap" overflow="hidden" textOverflow="ellipsis">
                    {project.name}
                  </Text>
                  <Text fontSize="md" whiteSpace="nowrap" overflow="hidden" textOverflow="ellipsis">
                    {project.subtitle}
                  </Text>
                </Box>
              </Box>
            </Box>
          </Link>
        ))}
      </Carousel>
    </Box>
  );
};

interface MoreProjectsSectionProps {
  projects: Project[];
  categories: string[];
  selectedCategory: string;
  onCategoryChange: any;
}

const MoreProjectsSection = ({ projects, categories, selectedCategory, onCategoryChange }: MoreProjectsSectionProps) => {
  return (
    <Box mt="4vh">
      <Flex alignItems="center" marginBottom="20px">
        <Text fontSize="2xl">More projects</Text>
        <Select placeholder="Select category" onChange={onCategoryChange} value={selectedCategory} ml="40px" maxW="300px">
          {categories.map((category, index) => (
            <option key={index} value={category}>
              {category}
            </option>
          ))}
        </Select>
      </Flex>
      {/* Ici, vous pouvez intégrer la logique d'affichage des cartes de projets */}
    </Box>
  );
};
