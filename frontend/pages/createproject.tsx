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
  IconButton,
} from "@chakra-ui/react";
import { AddIcon } from "@chakra-ui/icons";
import { useState, useEffect } from "react";
import { useAccount } from "wagmi";

import { callWriteMethod } from "@/ts/wagmiWrapper";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { ProjectCategory } from "@/ts/objects/Project";

import { Project } from "@/ts/objects/Project";
import { ProjectStep } from "@/ts/objects/ProjectStep";
import { TeamMember } from "@/ts/objects/TeamMember";

const CreateProject = () => {
  const { address } = useAccount();
  const toast = useToast();

  const [project, setProject] = useState(Project.createEmpty());
  const [mediaLinks, setMediaLinks] = useState([""]);

  useEffect(() => {
    document.title = "Nouveau projet";
  });

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    await callWriteMethod(BlockFundingFunctions.createNewContract, [project]);

    toast({
      title: "Projet créé",
      description: "Nous avons créé votre projet avec succès.",
      status: "success",
      duration: 9000,
      isClosable: true,
    });
  };

  // Convertir une date en format YYYY-MM-DD
  const toISODateString = (date: any) => {
    if (typeof date === "number") return new Date(date).toISOString().split("T")[0];
    else return date.toISOString().split("T")[0];
  };

  // Calculer la date minimale pour endDate et estimatedCompletionDate
  const calculateMinDate = (dateString: any, daysToAdd: any) => {
    if (dateString === "") return;
    const date = new Date(dateString);
    date.setDate(date.getDate() + daysToAdd);
    return toISODateString(date);
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = event.target;
    setProject((prevProject) => updateProjectField(prevProject, name, value));
  };

  function updateProjectField(project: Project, fieldName: string, value: string): Project {
    const updatedProject = new Project(
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
        updatedProject.campaignStartingDateTimestamp = new Date(value).getTime() / 1000;
        updatedProject.campaignEndingDateTimestamp = new Date(value).getTime() / 1000 + 7 * 24 * 60 * 60;
        updatedProject.estimatedProjectReleaseDateTimestamp = new Date(value).getTime() / 1000 + 14 * 24 * 60 * 60;
        break;
      case "campaignEndingDateTimestamp":
        updatedProject.campaignEndingDateTimestamp = new Date(value).getTime() / 1000;
        updatedProject.estimatedProjectReleaseDateTimestamp = new Date(value).getTime() / 1000 + 7 * 24 * 60 * 60;
        break;
      case "estimatedProjectReleaseDateTimestamp":
        updatedProject.estimatedProjectReleaseDateTimestamp = new Date(value).getTime() / 1000;
        break;
      case "targetWallet":
        updatedProject.targetWallet = value;
        break;
      case "owner":
        updatedProject.owner = value;
        break;
      case "totalFundsHarvested":
        updatedProject.totalFundsHarvested = BigInt(value);
        break;
      case "projectCategory":
        updatedProject.projectCategory = ProjectCategory[value as keyof typeof ProjectCategory];
        break;
      case "name":
        updatedProject.name = value;
        break;
        updatedProject.subtitle = value;
        break;
      case "description":
        updatedProject.description = value;
        break;
      case "mediaURI":
        updatedProject.mediaURI = value;
        break;
      // Pour teamMembers et projectSteps, vous aurez besoin d'une logique spécifique de mise à jour
      // car ils sont des tableaux d'objets. Voici un exemple simpliste pour illustrer:
      case "teamMembers":
        // Mettez à jour teamMembers ici. Vous aurez probablement besoin d'une logique plus complexe.
        break;
      case "projectSteps":
        // Mettez à jour projectSteps ici. Vous aurez probablement besoin d'une logique plus complexe.
        break;
      default:
        console.warn(`Field ${fieldName} is not recognized or cannot be updated directly.`);
    }

    return updatedProject;
  }

  return (
    <Box p={8}>
      <form onSubmit={handleSubmit}>
        <Stack spacing={4}>
          <FormControl isRequired>
            <FormLabel>Nom du projet</FormLabel>
            <Input name="name" value={project.name} onChange={handleInputChange} placeholder="Nom du projet" />
          </FormControl>
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
          <FormControl isRequired>
            <FormLabel>Date de début</FormLabel>
            <Input
              type="date"
              min={project.campaignStartingDateTimestamp}
              name="campaignStartingDateTimestamp"
              value={toISODateString(project.campaignStartingDateTimestamp * 1000)}
              onChange={handleInputChange}
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Date de fin</FormLabel>
            <Input
              type="date"
              min={project.campaignEndingDateTimestamp}
              name="campaignEndingDateTimestamp"
              value={toISODateString(project.campaignEndingDateTimestamp * 1000)}
              onChange={handleInputChange}
            />
          </FormControl>
          <FormControl>
            <FormLabel>Date estimée de réalisation</FormLabel>
            <Input
              type="date"
              min={project.estimatedProjectReleaseDateTimestamp}
              name="estimatedProjectReleaseDateTimestamp"
              value={toISODateString(project.estimatedProjectReleaseDateTimestamp * 1000)}
              onChange={handleInputChange}
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Lien vers la bannière du projet</FormLabel>
            <Input name="mediaURI" value={project.mediaURI} onChange={handleInputChange} placeholder="http://exemple.com/media.jpg" />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Liens des médias</FormLabel>
            {mediaLinks.map((link, index) => (
              <Input key={index} value={link} onChange={handleInputChange} placeholder="http://exemple.com/media.jpg" />
            ))}
            <IconButton aria-label="Ajouter un lien média" icon={<AddIcon />} mt={2} />
          </FormControl>
          {address ? (
            <Button mt={4} colorScheme="teal" type="submit">
              Créer Projet
            </Button>
          ) : (
            <Button mt={4} isDisabled={true} colorScheme="teal" type="submit">
              Please connect to your wallet first
            </Button>
          )}
        </Stack>
      </form>
    </Box>
  );
};

export default CreateProject;
