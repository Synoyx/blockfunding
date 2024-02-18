import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalFooter, ModalBody, Spinner } from "@chakra-ui/react";

export const WaitingForValidatingTransaction = ({ isOpen, onClose }: any) => {
  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered>
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Attente de la signature de la transaction</ModalHeader>

        <ModalBody>
          <Spinner size="xs" mr="1rem" /> Veuillez signer la transaction grâce à votre wallet.
        </ModalBody>
        <ModalFooter></ModalFooter>
      </ModalContent>
    </Modal>
  );
};
