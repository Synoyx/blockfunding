"use client";

import { Box, Button, Text, Flex, Select, Image } from "@chakra-ui/react";
import "react-responsive-carousel/lib/styles/carousel.min.css";
import { Carousel } from "react-responsive-carousel";
import { useEffect, useState } from "react";
import Link from "next/link";
import { useAccount } from "wagmi";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import Loader from "@/components/tools/Loader";
import { Project, ProjectCategory } from "@/ts/objects/Project";
import { ProjectCard } from "@/components/projectCard";

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
          <MoreProjectsSection projects={projects} />
        </>
      )}
    </Flex>
  );
}

interface LastProjectsSectionProps {
  projects: Project[];
}

const LastProjectsSection = ({ projects }: LastProjectsSectionProps) => {
  const { address } = useAccount();
  const [doesUsedAlreadyHaveRunningProject, setDoesUsedAlreadyHaveRunningProject] = useState<boolean>(false);

  useEffect(() => {
    if (address != undefined) {
      let ret = false;
      for (let project of projects) {
        if (project.owner == address && project.estimatedProjectReleaseDateTimestamp < new Date().getTime() / 1000) {
          ret = true;
        }
      }
      setDoesUsedAlreadyHaveRunningProject(ret);
    } else {
      setDoesUsedAlreadyHaveRunningProject(false);
    }
  }, [address]);

  return (
    <Box>
      <Flex justifyContent="space-between" alignItems="center" mb="15px">
        <Text fontSize="2xl">Most popular projects</Text>
        {address ? (
          doesUsedAlreadyHaveRunningProject ? (
            <Button bg="red.500" isDisabled={true} color="white">
              You already have a running project
            </Button>
          ) : (
            <Link href={process.env.NODE_ENV === "development" ? "/CreateProject" : "/createproject"}>
              <Button bg="green.500" color="white">
                Create project
              </Button>
            </Link>
          )
        ) : (
          <Button mt={4} isDisabled={true} colorScheme="teal" type="submit">
            Please connect to your wallet before creating project
          </Button>
        )}
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
            key={"link" + index}
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
}

const MoreProjectsSection = ({ projects }: MoreProjectsSectionProps) => {
  return (
    <Box mt="4vh">
      <Flex alignItems="center" marginBottom="20px" direction="column">
        <Text fontSize="2xl">More projects</Text>
        <Flex>
          {projects.map((project) => (
            <ProjectCard key={project.name} project={project}></ProjectCard>
          ))}
        </Flex>
      </Flex>
    </Box>
  );
};
