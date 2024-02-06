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
import { ProjectCategory } from "@/app/js/objects/Project";

const CreateProject = () => {
  const minDate = new Date().toISOString().split("T")[0];

  const [project, setProject] = useState({
    name: "",
    subtitle: "",
    description: "",
    walletAddress: "",
    fundingGoal: "",
    startDate: minDate,
    endDate: minDate,
    estimatedCompletionDate: minDate,
    category: "",
    mediaLinks: "",
  });

  const [mediaLinks, setMediaLinks] = useState([""]);
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [estimatedCompletionDate, setEstimatedCompletionDate] = useState("");

  const toast = useToast();

  const handleMediaLinkChange = (index: number, value: string) => {
    const updatedMediaLinks = [...mediaLinks];
    updatedMediaLinks[index] = value;
    setMediaLinks(updatedMediaLinks);
  };

  const addMediaLink = () => {
    setMediaLinks([...mediaLinks, ""]);
  };

  const handleChange = (e: any) => {
    const { name, value } = e.target;
    if (name === "startDate") {
      setStartDate(value);
    } else if (name === "endDate") {
      setEndDate(value);
    } else if (name === "estimatedCompletionDate") {
      setEstimatedCompletionDate(value);
    }
    setProject((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e: any) => {
    e.preventDefault();
    // Ici, vous implémenteriez la logique pour traiter et envoyer ces données
    // Par exemple, sauvegarder dans un état global, envoyer à un backend, etc.
    console.log(project);
    toast({
      title: "Projet créé",
      description: "Nous avons créé votre projet avec succès.",
      status: "success",
      duration: 9000,
      isClosable: true,
    });
  };

  // Mettre à jour les états pour les dates minimales autorisées
  useEffect(() => {
    if (startDate) {
      setEndDate(calculateMinDate(startDate, 7)); // endDate doit être au moins 1 semaine après startDate
    }
    if (endDate) {
      setEstimatedCompletionDate(calculateMinDate(endDate, 7)); // estimatedCompletionDate doit être au moins 1 semaine après endDate
    }
  }, [startDate, endDate]);

  // Convertir une date en format YYYY-MM-DD
  const toISODateString = (date: any) => {
    return date.toISOString().split("T")[0];
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
            <Input name="name" value={project.name} onChange={handleChange} placeholder="Nom du projet" />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Sous-titre</FormLabel>
            <Input name="subtitle" value={project.subtitle} onChange={handleChange} placeholder="Sous-titre" />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Description</FormLabel>
            <Textarea
              name="description"
              value={project.description}
              onChange={handleChange}
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
                value={project.walletAddress}
                onChange={handleChange}
                placeholder="0x..."
                required
              />
            </InputGroup>
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Montant demandé (en Wei)</FormLabel>
            <Input name="fundingGoal" value={project.fundingGoal} onChange={handleChange} type="number" placeholder="Montant en Wei" />
          </FormControl>
          {/* Répétez pour les autres champs, en adaptant selon les besoins */}
          <FormControl isRequired>
            <FormLabel>Catégorie</FormLabel>
            <Select name="category" value={project.category} onChange={handleChange} placeholder="Sélectionnez une catégorie">
              {Object.values(ProjectCategory).map((category) => (
                <option key={category} value={category}>
                  {category}
                </option>
              ))}
            </Select>
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Date de début</FormLabel>
            <Input type="date" min={calculateMinDate(minDate, 0)} name="startDate" value={project.startDate} onChange={handleChange} />
          </FormControl>
          <FormControl isRequired>
            <FormLabel>Date de fin</FormLabel>
            <Input type="date" min={calculateMinDate(startDate, 7)} name="endDate" value={project.endDate} onChange={handleChange} />
          </FormControl>
          <FormControl>
            <FormLabel>Date estimée de réalisation</FormLabel>
            <Input
              type="date"
              min={calculateMinDate(endDate, 7)}
              name="estimatedCompletionDate"
              value={project.estimatedCompletionDate}
              onChange={handleChange}
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
          <Button mt={4} colorScheme="teal" type="submit">
            Créer Projet
          </Button>
        </Stack>
      </form>
    </Box>
  );
};

export default CreateProject;