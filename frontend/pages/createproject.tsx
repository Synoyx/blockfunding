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

  const minDate = new Date().toISOString().split("T")[0];

  useEffect(() => {
    document.title = "Nouveau projet";
  });

  const handleMediaLinkChange = (index: number, value: string) => {
    const updatedMediaLinks = [...mediaLinks];
    updatedMediaLinks[index] = value;
    setMediaLinks(updatedMediaLinks);
  };

  const addMediaLink = () => {
    setMediaLinks([...mediaLinks, ""]);
  };

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

  const setStartDate = (startDate: any) => {
    project.campaignStartingDateTimestamp = new Date(startDate).getTime() / 1000;
    setEndDate(calculateMinDate(startDate, 7)); // endDate doit être au moins 1 semaine après startDate
  };

  const setEndDate = (endDate: any) => {
    project.campaignEndingDateTimestamp = new Date(endDate).getTime() / 1000;
    setEstimatedCompletionDate(calculateMinDate(endDate, 7)); // estimatedCompletionDate doit être au moins 1 semaine après endDate
  };

  const setEstimatedCompletionDate = (estimatedCompletionDate: any) => {
    project.estimatedProjectReleaseDateTimestamp = new Date(estimatedCompletionDate).getTime() / 1000;
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

  return (
    <Box p={8}>
      <form onSubmit={handleSubmit}>
        <Stack spacing={4}>
          <FormControl isRequired>
            <FormLabel>Nom du projet</FormLabel>
            <Input name="name" value={project.name} onChange={(e: any) => (project.name = e.target.value)} placeholder="Nom du projet" />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Sous-titre</FormLabel>
            <Input
              name="subtitle"
              value={project.subtitle}
              onChange={(e: any) => (project.subtitle = e.target.value)}
              placeholder="Sous-titre"
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Description</FormLabel>
            <Textarea
              name="description"
              value={project.description}
              onChange={(e: any) => (project.description = e.target.value)}
              placeholder="Description détaillée du projet"
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Adresse du wallet Ethereum</FormLabel>
            <InputGroup>
              <InputLeftAddon children="ETH" />
              <Input
                name="walletAddress"
                pattern="^0x[a-fA-F0-9]{40}$"
                type="text"
                value={project.targetWallet}
                onChange={(e: any) => (project.targetWallet = e.target.value)}
                placeholder="0x..."
                required
              />
            </InputGroup>
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Catégorie</FormLabel>
            <Select
              name="category"
              value={project.projectCategory}
              onChange={(e: any) => {
                console.log(e.target);
                project.projectCategory = e.target.value;
              }}
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
              name="startDate"
              value={toISODateString(project.campaignStartingDateTimestamp)}
              onChange={(e: any) => setStartDate(e.target.value)}
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Date de fin</FormLabel>
            <Input
              type="date"
              min={project.campaignEndingDateTimestamp}
              name="endDate"
              value={toISODateString(project.campaignEndingDateTimestamp)}
              onChange={(e: any) => setEndDate(e.target.value)}
            />
          </FormControl>
          <FormControl>
            <FormLabel>Date estimée de réalisation</FormLabel>
            <Input
              type="date"
              min={project.estimatedProjectReleaseDateTimestamp}
              name="estimatedCompletionDate"
              value={toISODateString(project.estimatedProjectReleaseDateTimestamp)}
              onChange={(e: any) => setEstimatedCompletionDate(e.target.value)}
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Lien vers la bannière du projet</FormLabel>
            <Input
              name="name"
              value={project.mediaURI}
              onChange={(e: any) => (project.mediaURI = e.target.value)}
              placeholder="http://exemple.com/media.jpg"
            />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Liens des médias</FormLabel>
            {mediaLinks.map((link, index) => (
              <Input
                key={index}
                value={link}
                onChange={(e) => handleMediaLinkChange(index, e.target.value)}
                placeholder="http://exemple.com/media.jpg"
              />
            ))}
            <IconButton aria-label="Ajouter un lien média" icon={<AddIcon />} onClick={addMediaLink} mt={2} />
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
