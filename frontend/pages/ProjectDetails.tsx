"use client";

import { Box, Heading, Text, Image, Link, Flex, HStack, VStack, Stack, Icon, Button } from "@chakra-ui/react";
import { useSearchParams } from "next/navigation";
import { useState, useEffect } from "react";
import { useAccount } from "wagmi";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import { weiToEth, getReadableDateFromTimestampSecond } from "@/ts/tools";
import Loader from "@/components/tools/Loader";
import { Project } from "@/ts/objects/Project";

const ProjectDetails = () => {
  const [project, setProject] = useState<Project | undefined>(undefined);
  const [isUserProjectOwner, setIsUserProjectOwner] = useState<boolean>(false);
  let { address } = useAccount();
  const params = useSearchParams();
  const { projects } = useBlockFundingContractContext();
  const projectId = params!.get("id");

  useEffect(() => {
    setProject(projects[+projectId!]);
  }, [projectId, projects]);

  useEffect(() => {
    if (project !== undefined) {
      console.log("Toto " + address);
      console.log("Tata " + project!.owner);
      setIsUserProjectOwner(address === project!.owner);
    } else setIsUserProjectOwner(false);
  }, [address, project]);

  return (
    <>
      {project == undefined ? (
        <Loader />
      ) : (
        <Flex direction="column" align="center" maxW="1200px" m="auto" p={5}>
          <Box width="full" overflow="hidden" borderRadius="lg" mb={5}>
            <Image src={project!.mediasURI[0]} alt="Project banner" width="full" height="auto" />
          </Box>
          <Flex direction={{ base: "column", lg: "row" }} width="full" gap={10}>
            <VStack align="start" flex={10} spacing={6} p={4} borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
              <Heading size="2xl" lineHeight="shorter">
                {project!.name}
              </Heading>
              <Text fontSize="2xl" fontWeight="bold" color="gray.600">
                {project!.subtitle}
              </Text>
              <Text fontSize="lg" color="gray.500">
                {project!.description}
              </Text>
            </VStack>
            <Stack direction={{ base: "column" }} spacing={4} flex={1} ml={{ lg: 5 }}>
              {isUserProjectOwner ? (
                <Box p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
                  <Button>Manage project</Button>
                </Box>
              ) : (
                <></>
              )}

              <Box p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
                <Text fontSize="sm">
                  Actually, {weiToEth(project!.currentFunding).toString()} ETH have been gathered on{" "}
                  {weiToEth(project!.fundingRequested).toString()} ETH requested.
                </Text>
                <Link href={`https://etherscan.io/address/${project!.targetWallet}`} isExternal color="blue.500" fontWeight="medium">
                  {project!.targetWallet}
                </Link>
              </Box>
              <VStack align="stretch" p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
                {[
                  project!.campaignStartingDateTimestamp,
                  project!.campaignEndingDateTimestamp,
                  project!.estimatedProjectReleaseDateTimestamp,
                ].map((timestamp, index) => (
                  <HStack key={index}>
                    <Icon name="calendar" />
                    <Text fontSize="sm">{getReadableDateFromTimestampSecond(timestamp)}</Text>
                  </HStack>
                ))}
              </VStack>
            </Stack>
          </Flex>
        </Flex>
      )}
    </>
  );
};

export default ProjectDetails;
