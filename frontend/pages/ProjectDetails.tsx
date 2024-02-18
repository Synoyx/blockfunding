"use client";

import { Box, Heading, Text, Image, Link, Flex, VStack, Stack, Button, useDisclosure, Spinner } from "@chakra-ui/react";
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
import { Vote, VoteType } from "@/ts/objects/Vote";
import { FundProjectModal } from "@/components/modals/FundProjectModal";
import { StartVoteModal } from "@/components/modals/StartVoteModal";
import { SendVoteModal } from "@/components/modals/SendVoteModal";
import { WaitingForValidatingTransaction } from "@/components/modals/WaitingForValidatingTransaction";
import { WaitingForTransactionExecution } from "@/components/modals/WaitingForTransactionExecution";

import { getData } from "@/ts/nftStorageWrapper";

import "@/assets/css/verticalTimeline.css";
import { getDonationAmount, getCurrentVote, getProject, isProjectCanceledOrLastStepValidated } from "@/ts/objects/BlockFundingProjectContract";

const ProjectDetails = () => {
  const [project, setProject] = useState<Project | undefined>(undefined);
  const [donationAmount, setDonationAmount] = useState<BigInt>(0n);
  const [selectedVoteType, setSelectedVoteType] = useState<VoteType>(VoteType.WithdrawProjectToFinancers);
  const [currentVote, setCurrentVote] = useState<Vote>(Vote.createEmpty());
  const [leftAmountBalance, setLeftAmountBalance] = useState<BigInt>(0n);
  const [isProjectCanceledOrLastStepValidatedValue, setIsProjectCanceledOrLastStepValidatedValue] = useState<boolean>(false);
  const [isUserProjectOwner, setIsUserProjectOwner] = useState<boolean>(false);
  const [isUserFinancer, setIsUserFinancer] = useState<boolean>(false); //TODO
  const [active, setActive] = useState("Project");
  let { address } = useAccount();
  const params = useSearchParams();
  const { projects } = useBlockFundingContractContext();

  const projectId = params!.get("id");

  const fundProjectModalDisclosure = useDisclosure();
  const waitingForValidatingTransactionlDisclosure = useDisclosure();
  const waitingForTransactionExecutionlDisclosure = useDisclosure();
  const startVoteModalDisclosure = useDisclosure();
  const sendVoteModalDisclosure = useDisclosure(); //TODO
  const endVoteModalDisclosure = useDisclosure(); //TODO

  useEffect(() => {
    async function test() {
      const message: string = await getData("bafkreiaerzwc75cplvwyfsawm5qyylpmlj2biwygmerv3wb5iknwgptbuu");
      //alert("Message = " + message);
    }
    setProject(getProjectFromComputedId());
    test(); //TODO change handling of messages
  }, [projectId, projects]);

  useEffect(() => {
    async function loadDonationAmount(contractAddress: any) {
      const result: any = await getDonationAmount(contractAddress, address);
      if (result != undefined) setDonationAmount(result);
    }

    async function loadCurrentVote(contractAddress: any) {
      const result: any = await getCurrentVote(contractAddress);
      if (result != undefined) setCurrentVote(result);
    }

    async function loadIsProjectFinished(contractAddress: any) {
      const result: any = await isProjectCanceledOrLastStepValidated(contractAddress);
      if (result != undefined) setIsProjectCanceledOrLastStepValidatedValue(result);
    }

    if (project !== undefined) {
      loadDonationAmount(project!.address);
      loadCurrentVote(project!.address);
      loadIsProjectFinished(project!.address);

      const amountThatWillBeConsumedInFuture = project!.projectSteps.reduce((acc, step) => {
        if (!step.hasBeenValidated) {
          return acc + (step.amountNeeded - step.amountFunded);
        }
        return acc;
      }, 0);

      setLeftAmountBalance(BigInt(project!.totalFundsHarvested - amountThatWillBeConsumedInFuture))
      setIsUserProjectOwner(address === project!.owner);
      document.title = project!.name;
    } else setIsUserProjectOwner(false);
  }, [address, project]);

  useEffect(() => {
    document.title = "Détails du projet";
  });

  function getProjectFromComputedId(): Project {
    for (let proj of projects) {
      if (proj.name == projectId) return proj;
    }
    return projects[0];
  }

  return (
    <>
      {project == undefined ? (
        <Loader />
      ) : (
        <Flex direction="column" align="center" maxW="80vw" m="auto" p={5}>
          <WaitingForValidatingTransaction
            isOpen={waitingForValidatingTransactionlDisclosure.isOpen}
            onClose={waitingForValidatingTransactionlDisclosure.onClose}
          />
          <WaitingForTransactionExecution
            isOpen={waitingForTransactionExecutionlDisclosure.isOpen}
            onClose={waitingForTransactionExecutionlDisclosure.onClose}
          />
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
                <ProgressBar goal={weiToEth(project!.getTotalFundsRequested())} current={weiToEth(project!.totalFundsHarvested)} />
                <Flex mt="10px" alignItems="center">
                  <Text fontSize="md" fontWeight="bold" mr="10px">
                    Objectif :
                  </Text>
                  <Text fontSize="md">{Math.round(weiToEth(project!.getTotalFundsRequested()))} ETH</Text>
                </Flex>
                <Flex alignItems="center">
                  <Text fontSize="md" fontWeight="bold" mr="10px">
                    Récolté :
                  </Text>
                  <Text fontSize="md">{Math.round(weiToEth(project!.totalFundsHarvested))} ETH</Text>
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
                <Heading size="md" lineHeight="shorter" mb="10px">
                  Votre participation
                </Heading>
                {address ? (
                  <>
                    <Text align="center">
                      Vous avez donné : {donationAmount != undefined ? weiToEth(donationAmount).toString() : <Spinner />} ETH au projet
                    </Text>
                    {project!.campaignEndingDateTimestamp < new Date().getTime() / 1000 ? (
                      <Text align="center">La phase de financement est passée, vous ne pouvez plus ajouter de participation</Text>
                    ) : project!.campaignStartingDateTimestamp > new Date().getTime() / 1000 ? (
                      <Text align="center">
                        La phase de financement n'a pas encore commencé, vous ne pouvez pas ajouter de participation pour le moment
                      </Text>
                    ) : (
                      <>
                        <FundProjectModal
                          isOpen={fundProjectModalDisclosure.isOpen}
                          onClose={fundProjectModalDisclosure.onClose}
                          projectName={project!.name}
                          projectAddress={project!.address}
                          waitingTXValidationDisclosure={waitingForValidatingTransactionlDisclosure}
                          waitingTXExecutionDisclosure={waitingForTransactionExecutionlDisclosure}
                          endTXCallback={async (amountAdded: any) => {
                            const updatedProject = await getProject(project!.address);
                            setProject((oldProject) => updatedProject);
                          }}
                        />
                        <Button colorScheme="green" onClick={fundProjectModalDisclosure.onOpen}>
                          Participer
                        </Button>
                      </>
                    )}
                  </>
                ) : (
                  <Text align="center">Veuillez vous connecter pour pouvoir participer au projet</Text>
                )}
              </VStack>
              <VStack align="stretch" p={4} boxShadow="md" borderRadius="md" bg="white" borderColor="gray.200" borderWidth="1px">
                <Flex justifyContent="space-between">
                  <Heading size="md" lineHeight="shorter" mb="10px">
                    Vote
                  </Heading>
                  <Text></Text>
                </Flex>
                <Flex display={currentVote.isVoteRunning ? "block" : "none"}>
                  <Flex>
                    <ProgressBar goal={Number(currentVote.totalVotePower)} current={Number(currentVote.votePowerInFavorOfProposal)} />
                  </Flex>
                  <Flex display={isUserFinancer ? "block" : "none"}>
                    {currentVote.hasFinancerVoted 
                      ? (<Text align="center">Vous avez déjà voté</Text>)
                      : (<Button
                        colorScheme="green"
                        onClick={() => {
                          sendVoteModalDisclosure.onOpen();
                        }}
                      >Voter</Button>)
                    }
                  </Flex>
                  <SendVoteModal
                      isOpen={sendVoteModalDisclosure.isOpen}
                      onClose={sendVoteModalDisclosure.onClose}
                      voteType={selectedVoteType}
                      projectAddress={project!.address}
                      waitingTXValidationDisclosure={waitingForValidatingTransactionlDisclosure}
                      waitingTXExecutionDisclosure={waitingForTransactionExecutionlDisclosure}
                      endTXCallback={async () => {
                        const updatedProject = await getProject(project!.address);
                        setProject((oldProject) => updatedProject);
                      }}
                  />

                  <Flex display={currentVote.canVoteBeEnded() && currentVote.canUserEndVote(isUserProjectOwner, isUserFinancer) ? "block" : "none"}>
                    <Button
                        colorScheme="green"
                        onClick={() => {
                          endVoteModalDisclosure.onOpen();
                        }}
                      >Terminer le vote</Button>
                  </Flex>
                </Flex>
                <Flex display={!currentVote.isVoteRunning ? "block" : "none"}>
                  <Text align="center">Il n'y a pas de vote en cours</Text>
                  <Flex display={isUserProjectOwner && isProjectCanceledOrLastStepValidatedValue ? "block" : "none"} alignItems="center">
                      <Button
                        colorScheme="green"
                        onClick={() => {
                          setSelectedVoteType(VoteType.ValidateStep);
                          startVoteModalDisclosure.onOpen();
                        }}
                      >Start validate current step vote</Button>
                      <Button 
                        display={isUserProjectOwner && isProjectCanceledOrLastStepValidatedValue ? "block" : "none"}
                        colorScheme="orange"
                        onClick={() => {
                          setSelectedVoteType(VoteType.AddFundsForStep);
                          startVoteModalDisclosure.onOpen(); //TODOChange this modal to the good one
                        }}
                      >State add funds to current step vote</Button>
                    </Flex>
                    --> Add vote add funds modal here
                </Flex>
                <Flex display={isUserFinancer && isProjectCanceledOrLastStepValidatedValue ? "block" : "none"} alignItems="center">
                  <Button
                        colorScheme="red"
                        onClick={() => {
                          setSelectedVoteType(VoteType.WithdrawProjectToFinancers);
                          startVoteModalDisclosure.onOpen();
                        }}
                      >Vote for cancelling the project</Button>
                </Flex>

                <StartVoteModal
                      isOpen={startVoteModalDisclosure.isOpen}
                      onClose={startVoteModalDisclosure.onClose}
                      voteType={selectedVoteType}
                      projectAddress={project!.address}
                      waitingTXValidationDisclosure={waitingForValidatingTransactionlDisclosure}
                      waitingTXExecutionDisclosure={waitingForTransactionExecutionlDisclosure}
                      endTXCallback={async () => {
                        const updatedProject = await getProject(project!.address);
                        setProject((oldProject) => updatedProject);
                      }}
                    />
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
