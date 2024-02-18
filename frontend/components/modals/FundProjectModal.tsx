import {
  useDisclosure,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalCloseButton,
  ModalBody,
  Button,
} from "@chakra-ui/react";

export const FundProjectModal = () => {
  let { isOpen, onClose, onToggle } = useDisclosure();

  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered>
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Participer au projet</ModalHeader>
        <ModalCloseButton />

        <ModalBody>
          Félicitations, Vous avez décidé de participer à un projet d'avenir !\r\n Veuillez saisir le montant de votre participation et
          cliquer sur le bouton valider pour devenir un financer et participer à la communauté du projet XXXXX
        </ModalBody>
        <ModalFooter>
          <Button colorScheme="blue" mr={3} onClick={onClose}>
            Annuler
          </Button>
          <Button colorScheme="green">Valider</Button>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
};
