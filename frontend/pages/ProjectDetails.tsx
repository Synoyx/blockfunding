"use client";

import { Box, Heading, Text, Image, Link, Flex, VStack, Stack, Button } from "@chakra-ui/react";
import { VerticalTimeline, VerticalTimelineElement } from "react-vertical-timeline-component";
import { CheckCircleIcon, LockIcon, UnlockIcon } from "@chakra-ui/icons";

import "react-vertical-timeline-component/style.min.css";
import { useSearchParams } from "next/navigation";
import { useState, useEffect } from "react";
import { useAccount } from "wagmi";

import { useBlockFundingContractContext } from "@/contexts/blockFundingContractContext";
import { weiToEth, getReadableDateFromTimestampSecond } from "@/ts/tools";
import Loader from "@/components/tools/Loader";
import { Project } from "@/ts/objects/Project";

import { getData } from "@/ts/nftStorageWrapper";

import "@/assets/css/verticalTimeline.css";

const ProjectDetails = () => {
  const [project, setProject] = useState<Project | undefined>(undefined);
  const [isUserProjectOwner, setIsUserProjectOwner] = useState<boolean>(false);
  let { address } = useAccount();
  const params = useSearchParams();
  const { projects } = useBlockFundingContractContext();
  const projectId = params!.get("id");
  const [active, setActive] = useState("Project");

  useEffect(() => {
    async function test() {
      const message: string = await getData("bafkreiaerzwc75cplvwyfsawm5qyylpmlj2biwygmerv3wb5iknwgptbuu");
      //alert("Message = " + message);
    }

    setProject(projects[+projectId!]);
    test();
  }, [projectId, projects]);

  useEffect(() => {
    if (project !== undefined) {
      setIsUserProjectOwner(address === project!.owner);
      document.title = project!.name;
    } else setIsUserProjectOwner(false);
  }, [address, project]);

  useEffect(() => {
    document.title = "Détails du projet";
  });

  return (
    <>
      {project == undefined ? (
        <Loader />
      ) : (
        <Flex direction="column" align="center" maxW="80vw" m="auto" p={5}>
          <Box width="full" overflow="hidden" borderRadius="lg" mb={5}>
            <Image src={project!.mediaURI} alt="Project banner" width="full" height="auto" />
          </Box>
          <Flex direction={{ base: "column", lg: "row" }} width="full" gap={5}>
            <VStack align="start" flex={10} spacing={6} p={4} borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
              <Flex width="100%">
                {["Project", "Timeline", "Team", "Étapes du projet"].map((tabName) => (
                  <Button
                    flex="1"
                    key={tabName}
                    borderRadius="8px 8px 0 0"
                    borderBottom={active === tabName ? "none" : "2px solid grey !important"}
                    borderTop={active === tabName ? "2px solid #B5B5B5 !important" : "none"}
                    borderRight={active === tabName ? "2px solid #B5B5B5 !important" : "none"}
                    borderLeft={active === tabName ? "2px solid #B5B5B5 !important" : "none"}
                    fontSize="20px"
                    _focus={{ outline: "none" }}
                    padding="10px 60px"
                    cursor="pointer"
                    opacity={active === tabName ? 1 : 0.4}
                    border="0"
                    outline="0"
                    bg="transparent"
                    transition="all 1s ease-out"
                    onClick={() => setActive(tabName)}
                  >
                    {tabName}
                  </Button>
                ))}
              </Flex>
              <Flex display={active === "Project" ? "block" : "none"} width="100%">
                <Heading size="2xl" lineHeight="shorter">
                  {project!.name}
                </Heading>
                <Text fontSize="2xl" fontWeight="bold" color="gray.600">
                  {project!.subtitle}
                </Text>
                <Text fontSize="lg" color="gray.500">
                  <TextWithLineBreaks text={project!.description} />
                </Text>
              </Flex>

              <Flex display={active === "Timeline" ? "block" : "none"} width="100%" color="black">
                <VerticalTimeline lineColor="rgb(33, 150, 243)">
                  <VerticalTimelineElement
                    className="vertical-timeline-element--work"
                    contentStyle={{ background: "rgb(33, 150, 243)", color: "#fff" }}
                    contentArrowStyle={{ borderRight: "7px solid  rgb(33, 150, 243)" }}
                    date={getReadableDateFromTimestampSecond(project!.campaignStartingDateTimestamp)}
                    iconStyle={{ background: "rgb(33, 150, 243)", color: "#fff" }}
                    icon={<UnlockIcon />}
                  >
                    <h3 className="vertical-timeline-element-title">Début de la campagne de crowdfunding</h3>
                  </VerticalTimelineElement>
                  <VerticalTimelineElement
                    className="vertical-timeline-element--work"
                    contentStyle={{ background: "rgb(33, 150, 243)", color: "#fff" }}
                    contentArrowStyle={{ borderRight: "7px solid  rgb(33, 150, 243)" }}
                    date={getReadableDateFromTimestampSecond(project!.campaignEndingDateTimestamp)}
                    iconStyle={{ background: "rgb(33, 150, 243)", color: "#fff" }}
                    icon={<LockIcon />}
                  >
                    <h3 className="vertical-timeline-element-title">Fin de la campagne de crowdfunding</h3>
                  </VerticalTimelineElement>
                  <VerticalTimelineElement
                    className="vertical-timeline-element--work"
                    contentStyle={{ background: "rgb(33, 150, 243)", color: "#fff" }}
                    contentArrowStyle={{ borderRight: "7px solid  rgb(33, 150, 243)" }}
                    date={getReadableDateFromTimestampSecond(project!.estimatedProjectReleaseDateTimestamp)}
                    iconStyle={{ background: "rgb(33, 150, 243)", color: "#fff" }}
                    icon={<CheckCircleIcon />}
                  >
                    <h3 className="vertical-timeline-element-title">Date de fin du projet (estimée)</h3>
                  </VerticalTimelineElement>
                </VerticalTimeline>
              </Flex>
            </VStack>

            <Stack direction={{ base: "column" }} spacing={4} flex={1} ml={{ lg: 5 }} maxW="30%">
              <Box p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
                <Heading size="md" lineHeight="shorter" mb="10px">
                  Financement
                </Heading>
                <ProgressBar goal={weiToEth(BigInt(project!.fundingRequested))} current={weiToEth(BigInt(project!.totalFundsHarvested))} />
                <Flex mt="10px" alignItems="center">
                  <Text fontSize="md" fontWeight="bold" mr="10px">
                    Objectif :
                  </Text>
                  <Text fontSize="md">{Math.round(weiToEth(BigInt(project!.fundingRequested)))} ETH</Text>
                </Flex>
                <Flex alignItems="center">
                  <Text fontSize="md" fontWeight="bold" mr="10px">
                    Récolté :
                  </Text>
                  <Text fontSize="md">{Math.round(weiToEth(BigInt(project!.totalFundsHarvested)))} ETH</Text>
                </Flex>
                <Flex alignItems="center" width="100%">
                  <Text fontSize="md" fontWeight="bold" mr="10px" whiteSpace="nowrap">
                    Wallet projet :
                  </Text>
                  <Link
                    href={`https://etherscan.io/address/${project!.targetWallet}`}
                    isExternal
                    color="blue.500"
                    fontWeight="medium"
                    flex="1"
                    style={{ minWidth: 0 }}
                  >
                    <Text fontSize="md" whiteSpace="nowrap" overflow="hidden" textOverflow="ellipsis" style={{ minWidth: 0 }}>
                      {project!.targetWallet}
                    </Text>
                  </Link>
                </Flex>
              </Box>
              <VStack align="stretch" p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
                <Flex justifyContent="space-between">
                  <Heading size="md" lineHeight="shorter" mb="10px">
                    Vote
                  </Heading>
                  <Text>Historique</Text>
                </Flex>
                <Text align="center">Il n'y a pas de vote en cours</Text>
                <Flex display={isUserProjectOwner ? "block" : "none"} alignItems="center">
                  <Button bg="green.500" color="white">
                    Start validate current step vote
                  </Button>
                  <Button bg="orange" color="white">
                    State add funds to current step vote
                  </Button>
                </Flex>
              </VStack>
            </Stack>
          </Flex>
        </Flex>
      )}
    </>
  );
};

interface TextWithLineBreaksProps {
  text: string;
}

const TextWithLineBreaks = ({ text }: TextWithLineBreaksProps) => {
  // Diviser le texte à chaque '\n' et mapper sur le tableau pour insérer des <br /> entre les segments
  const paragraphs = text.split("\n").map((paragraph, index, array) =>
    // Ne pas ajouter de <br /> après le dernier élément
    index < array.length - 1 ? (
      paragraph.length < 50 ? (
        <Text fontSize="xl" fontWeight="bold" key={index}>
          {paragraph}
          <br />
        </Text>
      ) : (
        <span key={index}>
          {paragraph}
          <br />
        </span>
      )
    ) : (
      <span key={index}>{paragraph}</span>
    )
  );

  return <Text>{paragraphs}</Text>;
};

interface ProgressBarProps {
  goal: number;
  current: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ goal, current }) => {
  const progressPercent = Math.min(Math.round((current / goal) * 100), 100);

  const containerStyles = {
    height: 20,
    width: "100%",
    backgroundColor: "#e0e0de",
    borderRadius: 50,
  };

  const fillerStyles: any = {
    height: "100%",
    width: `${progressPercent}%`,
    backgroundColor: "green",
    transition: "width 1s ease-in-out",
    borderRadius: "inherit",
    textAlign: "right",
  };

  const labelStyles = {
    padding: 5,
    color: "white",
    fontWeight: "bold",
  };

  return (
    <div style={containerStyles}>
      <div style={fillerStyles}>
        <span style={labelStyles}>{`${progressPercent}%`}</span>
      </div>
    </div>
  );
};

export default ProjectDetails;
