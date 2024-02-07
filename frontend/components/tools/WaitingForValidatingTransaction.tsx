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

const WaitingForValidatingTransaction = () => {
  let { isOpen, onToggle } = useDisclosure();
  isOpen = true;

  //<ModalCloseButton /> seems to not work properly, so removed it

  return (
    <Modal onClose={onToggle} isOpen={isOpen} isCentered>
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

export default WaitingForValidatingTransaction;
