import {
  useDisclosure,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalCloseButton,
  ModalBody,
  Spinner,
} from "@chakra-ui/react";

export const WaitingForValidatingTransaction = ({ isOpen, onClose }: any) => {
  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered>
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Waiting for transaction validation</ModalHeader>

        <ModalBody>
          <Spinner size="xs" mr="1rem" /> Please use your wallet to validate the transaction.
        </ModalBody>
        <ModalFooter></ModalFooter>
      </ModalContent>
    </Modal>
  );
};
