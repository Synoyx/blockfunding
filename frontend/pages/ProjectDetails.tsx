"use client";

import { Box, Heading, Text, Image, Link, Flex, HStack, VStack, Stack, Icon } from "@chakra-ui/react";
import { useSearchParams } from "next/navigation";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import { weiToEth, getReadableDateFromTimestampSecond } from "@/ts/tools";
import { Project } from "@/ts/objects/Project";

const ProjectDetails = () => {
  const params = useSearchParams();
  const projectId = params!.get("id");
  const { projects } = useBlockFundingContractContext();
  const project = projects[+projectId!];

  return (
    <Flex direction="column" align="center" maxW="1200px" m="auto" p={5}>
      <Box width="full" overflow="hidden" borderRadius="lg" mb={5}>
        <Image src={project.mediasURI[0]} alt="Project banner" width="full" height="auto" />
      </Box>
      <Flex direction={{ base: "column", lg: "row" }} width="full">
        <VStack align="start" flex={3} spacing={5}>
          <Heading size="xl">{project.name}</Heading>
          <Text fontSize="lg" fontWeight="semibold">
            {project.subtitle}
          </Text>
          <Text fontSize="md">{project.description}</Text>
        </VStack>
        <Stack direction={{ base: "column" }} spacing={4} flex={1} ml={{ lg: 5 }}>
          <Box p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
            <Text fontSize="sm">
              Actually, {weiToEth(project.currentFunding).toString()} ETH have been gathered on{" "}
              {weiToEth(project.fundingRequested).toString()} ETH requested.
            </Text>
            <Link href={`https://etherscan.io/address/${project.targetWallet}`} isExternal color="blue.500" fontWeight="medium">
              {project.targetWallet}
            </Link>
          </Box>
          <VStack align="stretch" p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
            {[project.campaignStartingDateTimestamp, project.campaignEndingDateTimestamp, project.estimatedProjectReleaseDateTimestamp].map(
              (timestamp, index) => (
                <HStack key={index}>
                  <Icon name="calendar" />
                  <Text fontSize="sm">{getReadableDateFromTimestampSecond(timestamp)}</Text>
                </HStack>
              )
            )}
          </VStack>
        </Stack>
      </Flex>
    </Flex>
  );
};

export default ProjectDetails;
