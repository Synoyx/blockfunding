import {
  Box,
  Button,
  FormControl,
  FormLabel,
  Input,
  Textarea,
  Select,
  Stack,
  InputGroup,
  InputLeftAddon,
  useToast,
  Flex,
  IconButton,
} from "@chakra-ui/react";
import { AddIcon, CloseIcon } from "@chakra-ui/icons";
import { useState, useEffect } from "react";
import { useAccount } from "wagmi";

import { callWriteMethod } from "@/ts/wagmiWrapper";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { ProjectCategory } from "@/ts/objects/Project";

import { Project } from "@/ts/objects/Project";
import { ProjectStep } from "@/ts/objects/ProjectStep";
import { TeamMember } from "@/ts/objects/TeamMember";
import { BiBox } from "react-icons/bi";

const CreateProject = () => {
  const { address } = useAccount();
  const toast = useToast();

  const [currentStep, setCurrentStep] = useState(1);
  const [project, setProject] = useState(Project.createEmpty());
  const [teamMembers, setTeamMembers] = useState([new TeamMember("", "", "", "", "", "")]);
  const [projectSteps, setProjectSteps] = useState([new ProjectStep("", "", 0, 0, false, 1, false)]);
  const [mediaLinks, setMediaLinks] = useState([""]);

  useEffect(() => {
    document.title = "Nouveau projet";
  });

  useEffect(() => {
    if (address === undefined) return;
    const updatedProject = new Project(
      project.address,
      project.campaignStartingDateTimestamp,
      project.campaignEndingDateTimestamp,
      project.estimatedProjectReleaseDateTimestamp,
      project.targetWallet,
      project.owner,
      project.totalFundsHarvested,
      project.projectCategory,
      project.name,
      project.subtitle,
      project.description,
      project.mediaURI,
      project.teamMembers,
      project.projectSteps
    );

    updatedProject.owner = address.toString();

    setProject((prevProject) => updatedProject);
  }, [address]);

  const goToNextStep = () => {
    setCurrentStep(currentStep + 1);
  };

  const goToPreviousStep = () => {
    setCurrentStep(currentStep - 1);
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = event.target;
    setProject((prevProject) => updateProjectField(prevProject, name, value));
  };

  function updateProjectField(project: Project, fieldName: string, value: string): Project {
    const updatedProject = new Project(
      project.address,
      project.campaignStartingDateTimestamp,
      project.campaignEndingDateTimestamp,
      project.estimatedProjectReleaseDateTimestamp,
      project.targetWallet,
      project.owner,
      project.totalFundsHarvested,
      project.projectCategory,
      project.name,
      project.subtitle,
      project.description,
      project.mediaURI,
      project.teamMembers,
      project.projectSteps
    );

    switch (fieldName) {
      case "campaignStartingDateTimestamp":
        updatedProject.campaignStartingDateTimestamp = Math.round(new Date(value).getTime() / 1000);
        updatedProject.campaignEndingDateTimestamp = Math.round(new Date(value).getTime() / 1000 + 7 * 24 * 60 * 60);
        updatedProject.estimatedProjectReleaseDateTimestamp = Math.round(new Date(value).getTime() / 1000 + 14 * 24 * 60 * 60);
        break;
      case "campaignEndingDateTimestamp":
        updatedProject.campaignEndingDateTimestamp = Math.round(new Date(value).getTime() / 1000);
        updatedProject.estimatedProjectReleaseDateTimestamp = Math.round(new Date(value).getTime() / 1000 + 7 * 24 * 60 * 60);
        break;
      case "estimatedProjectReleaseDateTimestamp":
        updatedProject.estimatedProjectReleaseDateTimestamp = Math.round(new Date(value).getTime() / 1000);
        break;
      case "targetWallet":
        updatedProject.targetWallet = value;
        break;
      case "owner":
        updatedProject.owner = value;
        break;
      case "totalFundsHarvested":
        updatedProject.totalFundsHarvested = +value;
        break;
      case "projectCategory":
        updatedProject.projectCategory = ProjectCategory[value as keyof typeof ProjectCategory];
        break;
      case "name":
        updatedProject.name = value;
        break;
      case "subtitle":
        updatedProject.subtitle = value;
        break;
      case "description":
        updatedProject.description = value;
        break;
      case "mediaURI":
        updatedProject.mediaURI = value;
        break;
      default:
        console.warn(`Field ${fieldName} is not recognized or cannot be updated directly.`);
    }

    return updatedProject;
  }

  const toISODateString = (date: any) => {
    if (typeof date === "number") return new Date(date).toISOString().split("T")[0];
    else return date.toISOString().split("T")[0];
  };

  const addTeamMember = () => {
    setTeamMembers([...teamMembers, new TeamMember("", "", "", "", "", "")]);
  };

  const removeTeamMember = (indexToRemove: any) => {
    setTeamMembers(teamMembers.filter((_, index) => index !== indexToRemove));
  };

  const addProjectStep = () => {
    setProjectSteps([...projectSteps, new ProjectStep("", "", 0, 0, false, projectSteps.length + 1, false)]);
  };

  const removeProjectStep = (indexToRemove: any) => {
    setProjectSteps(projectSteps.filter((_, index) => index !== indexToRemove));
  };

  const handleTeamMemberChange = (index: number, field: string, value: string) => {
    const updatedTeamMembers = [...teamMembers];
    const memberToUpdate = new TeamMember(
      updatedTeamMembers[index].firstName,
      updatedTeamMembers[index].lastName,
      updatedTeamMembers[index].description,
      updatedTeamMembers[index].photoLink,
      updatedTeamMembers[index].role,
      updatedTeamMembers[index].walletAddress
    );

    switch (field) {
      case "firstName":
        memberToUpdate.firstName = value;
        break;
      case "lastName":
        memberToUpdate.lastName = value;
        break;
      case "description":
        memberToUpdate.description = value;
        break;
      case "photoLink":
        memberToUpdate.photoLink = value;
        break;
      case "role":
        memberToUpdate.role = value;
        break;
      case "walletAddress":
        memberToUpdate.walletAddress = value;
        break;
      default:
        break;
    }

    updatedTeamMembers[index] = memberToUpdate;
    setTeamMembers(updatedTeamMembers);
  };

  const handleProjectStepChange = (index: number, field: string, value: string) => {
    const updatedProjectSteps = [...projectSteps];
    const stepToUpdate = new ProjectStep(
      updatedProjectSteps[index].name,
      updatedProjectSteps[index].description,
      updatedProjectSteps[index].amountNeeded,
      updatedProjectSteps[index].amountFunded,
      updatedProjectSteps[index].isFunded,
      updatedProjectSteps[index].orderNumber,
      updatedProjectSteps[index].hasBeenValidated
    );

    switch (field) {
      case "amountNeeded":
        stepToUpdate.amountNeeded = +value;
        break;
      case "amountFunded":
        stepToUpdate.amountFunded = +value;
        break;
      case "description":
        stepToUpdate.description = value;
        break;
      case "name":
        stepToUpdate.name = value;
        break;
      default:
        break;
    }

    updatedProjectSteps[index] = stepToUpdate;
    setProjectSteps(updatedProjectSteps);
  };

  const handleSubmit = async (e: any) => {
    project.teamMembers = teamMembers;
    project.projectSteps = projectSteps;

    e.preventDefault();
    await callWriteMethod(BlockFundingFunctions.createNewContract, [project.toJson()]);

    toast({
      title: "Projet créé",
      description: "Nous avons créé votre projet avec succès.",
      status: "success",
      duration: 9000,
      isClosable: true,
    });
  };

  return (
    <Box p={8}>
      <form onSubmit={handleSubmit}>
        <Stack spacing={4}>
          {currentStep === 1 && (
            <>
              <Flex>
                <FormControl isRequired mr="20px">
                  <FormLabel>Nom du projet</FormLabel>
                  <Input name="name" value={project.name} onChange={handleInputChange} placeholder="Nom du projet" />
                </FormControl>
                <FormControl isRequired>
                  <FormLabel>Catégorie</FormLabel>
                  <Select
                    name="projectCategory"
                    value={project.projectCategory}
                    onChange={handleInputChange}
                    placeholder="Sélectionnez une catégorie"
                  >
                    {Object.values(ProjectCategory).map((category) => (
                      <option key={category} value={category}>
                        {category}
                      </option>
                    ))}
                  </Select>
                </FormControl>
              </Flex>
              <FormControl isRequired>
                <FormLabel>Sous-titre</FormLabel>
                <Input name="subtitle" value={project.subtitle} onChange={handleInputChange} placeholder="Sous-titre" />
              </FormControl>
              <FormControl isRequired>
                <FormLabel>Description</FormLabel>
                <Textarea
                  name="description"
                  value={project.description}
                  onChange={handleInputChange}
                  placeholder="Description détaillée du projet"
                />
              </FormControl>
              <FormControl isRequired>
                <FormLabel>Adresse du wallet Ethereum</FormLabel>
                <InputGroup>
                  <InputLeftAddon children="ETH" />
                  <Input
                    name="targetWallet"
                    pattern="^0x[a-fA-F0-9]{40}$"
                    type="text"
                    value={project.targetWallet}
                    onChange={handleInputChange}
                    placeholder="0x..."
                    required
                  />
                </InputGroup>
              </FormControl>
              <FormControl isRequired>
                <FormLabel>Lien vers la bannière du projet</FormLabel>
                <Input name="mediaURI" value={project.mediaURI} onChange={handleInputChange} placeholder="http://exemple.com/media.jpg" />
              </FormControl>
              <Flex>
                <FormControl mr="8px" isRequired>
                  <FormLabel>Date de début</FormLabel>
                  <Input
                    type="date"
                    min={project.campaignStartingDateTimestamp}
                    name="campaignStartingDateTimestamp"
                    value={toISODateString(project.campaignStartingDateTimestamp * 1000)}
                    onChange={handleInputChange}
                  />
                </FormControl>
                <FormControl mr="8px" isRequired>
                  <FormLabel>Date de fin</FormLabel>
                  <Input
                    type="date"
                    min={project.campaignEndingDateTimestamp}
                    name="campaignEndingDateTimestamp"
                    value={toISODateString(project.campaignEndingDateTimestamp * 1000)}
                    onChange={handleInputChange}
                  />
                </FormControl>
                <FormControl mr="8px" isRequired>
                  <FormLabel>Date estimée de réalisation</FormLabel>
                  <Input
                    type="date"
                    min={project.estimatedProjectReleaseDateTimestamp}
                    name="estimatedProjectReleaseDateTimestamp"
                    value={toISODateString(project.estimatedProjectReleaseDateTimestamp * 1000)}
                    onChange={handleInputChange}
                  />
                </FormControl>
              </Flex>

              <Flex justify="end">
                <Button colorScheme="green" type="button" onClick={goToNextStep}>
                  Suivant
                </Button>
              </Flex>
            </>
          )}

          {currentStep === 2 && (
            <>
              <FormLabel>Membres de l'équipe</FormLabel>
              <Flex
                overflowX="scroll"
                paddingBottom="20px"
                sx={{
                  "&::-webkit-scrollbar": {
                    display: "block",
                    height: "8px",
                  },
                  "&::-webkit-scrollbar-track": {
                    background: "#f1f1f1",
                  },
                  "&::-webkit-scrollbar-thumb": {
                    background: "#888",
                  },
                  "&::-webkit-scrollbar-thumb:hover": {
                    background: "#555",
                  },
                  scrollbarColor: "#888 #f1f1f1",
                  scrollbarWidth: "thin",
                }}
              >
                {teamMembers.map((member, index) => (
                  <Box key={index} mr="20px" minWidth="250px" width="250px" position="relative">
                    <IconButton
                      aria-label="Supprimer le membre"
                      icon={<CloseIcon />}
                      size="sm"
                      position="absolute"
                      right="0"
                      top="0"
                      onClick={() => removeTeamMember(index)}
                      zIndex="1"
                      colorScheme="red"
                    />
                    <Stack spacing={4}>
                      <Input
                        placeholder="Prénom"
                        value={member.firstName}
                        isRequired
                        onChange={(e) => handleTeamMemberChange(index, "firstName", e.target.value)}
                      />
                      <Input
                        placeholder="Nom"
                        value={member.lastName}
                        isRequired
                        onChange={(e) => handleTeamMemberChange(index, "lastName", e.target.value)}
                      />
                      <Textarea
                        placeholder="Description"
                        value={member.description}
                        isRequired
                        onChange={(e) => handleTeamMemberChange(index, "description", e.target.value)}
                      />
                      <Input
                        placeholder="Lien photo"
                        value={member.photoLink}
                        isRequired
                        onChange={(e) => handleTeamMemberChange(index, "photoLink", e.target.value)}
                      />
                      <Input
                        placeholder="Rôle"
                        value={member.role}
                        onChange={(e) => handleTeamMemberChange(index, "role", e.target.value)}
                      />
                      <Input
                        placeholder="Adresse Wallet"
                        pattern="^0x[a-fA-F0-9]{40}$"
                        value={member.walletAddress}
                        isRequired
                        onChange={(e) => handleTeamMemberChange(index, "walletAddress", e.target.value)}
                      />
                    </Stack>
                  </Box>
                ))}
                <Flex justify="center" alignItems="center" justifyItems="center">
                  <Button colorScheme="green" onClick={addTeamMember} leftIcon={<AddIcon />}>
                    Ajouter un membre
                  </Button>
                </Flex>
              </Flex>

              <Flex justify="space-between">
                <Button colorScheme="orange" type="button" onClick={goToPreviousStep}>
                  Précédent
                </Button>
                <Button colorScheme="green" type="button" onClick={goToNextStep}>
                  Suivant
                </Button>
              </Flex>
            </>
          )}

          {currentStep === 3 && (
            <>
              <FormLabel>Étapes du projet</FormLabel>
              <Flex
                overflowX="scroll"
                paddingBottom="20px"
                sx={{
                  "&::-webkit-scrollbar": {
                    display: "block",
                    height: "8px",
                  },
                  "&::-webkit-scrollbar-track": {
                    background: "#f1f1f1",
                  },
                  "&::-webkit-scrollbar-thumb": {
                    background: "#888",
                  },
                  "&::-webkit-scrollbar-thumb:hover": {
                    background: "#555",
                  },
                  scrollbarColor: "#888 #f1f1f1",
                  scrollbarWidth: "thin",
                }}
              >
                {projectSteps.map((step, index) => (
                  <Box key={index} mr="20px" minWidth="250px" width="250px" position="relative">
                    <IconButton
                      aria-label="Supprimer l'étape"
                      icon={<CloseIcon />}
                      size="sm"
                      position="absolute"
                      right="0"
                      top="0"
                      onClick={() => removeProjectStep(index)}
                      zIndex="1"
                      colorScheme="red"
                    />
                    <Stack spacing={4}>
                      <Input
                        isRequired
                        placeholder="Nom de l'étape"
                        value={step.name}
                        onChange={(e) => handleProjectStepChange(index, "name", e.target.value)}
                      />
                      <Textarea
                        isRequired
                        placeholder="Description"
                        value={step.description}
                        onChange={(e) => handleProjectStepChange(index, "description", e.target.value)}
                      />
                      <Input
                        isRequired
                        placeholder="Montant nécessaire"
                        type="number"
                        value={step.amountNeeded.toString()}
                        onChange={(e) => handleProjectStepChange(index, "amountNeeded", e.target.value)}
                      />
                    </Stack>
                  </Box>
                ))}
                <Flex justify="center" alignItems="center" justifyItems="center">
                  <Button colorScheme="green.500" bg="green.500" color="white" onClick={addProjectStep} leftIcon={<AddIcon />}>
                    Ajouter une étape
                  </Button>
                </Flex>
              </Flex>

              <Flex justify="space-between">
                <Button colorScheme="orange" type="button" onClick={goToPreviousStep}>
                  Précédent
                </Button>
                {address ? (
                  <Button mt={4} colorScheme="teal" type="submit">
                    Créer Projet
                  </Button>
                ) : (
                  <Button mt={4} isDisabled={true} colorScheme="teal" type="submit">
                    Please connect to your wallet first
                  </Button>
                )}
              </Flex>
            </>
          )}
        </Stack>
      </form>
    </Box>
  );
};

export default CreateProject;
