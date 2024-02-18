import {
  Modal,
  Flex,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalCloseButton,
  ModalBody,
  Spinner,
  Text,
} from "@chakra-ui/react";

export const WaitingForTransactionExecution = ({ isOpen, onClose }: any) => {
  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered>
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Attente de l&apos;exécution de la transaction</ModalHeader>

        <ModalBody>
          <Flex alignItems="center" justify="center">
            <Spinner size="xl" mr="1rem" />
          </Flex>
          <Text mt="20px" align="center">
            Veuillez attendre l&apos;exécution de la transaction avant de continuer.
          </Text>
        </ModalBody>
        <ModalFooter></ModalFooter>
      </ModalContent>
    </Modal>
  );
};
