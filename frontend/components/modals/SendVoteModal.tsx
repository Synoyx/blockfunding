import {
  Modal,
  Flex,
  ModalOverlay,
  ModalContent,
  Button,
  ModalHeader,
  ModalFooter,
  ModalCloseButton,
  ModalBody,
  Spinner,
  Text,
} from "@chakra-ui/react";
import { callWriteMethod } from "@/ts/wagmiWrapper";
import { BlockFundingProjectFunctions } from "@/ts/objects/BlockFundingProjectContract";
import { VoteType } from "@/ts/objects/Vote";

export const SendVoteModal = ({
  isOpen,
  onClose,
  voteType,
  projectAddress,
  waitingTXValidationDisclosure,
  waitingTXExecutionDisclosure,
  endTXCallback,
}: any) => {
  const handleSubmit = async (vote: boolean) => {
    onClose();
    await callWriteMethod(
      BlockFundingProjectFunctions.sendVote,
      [vote],
      0n,
      projectAddress,
      () => {},
      (e: any) => {
        throw e;
      },
      (pendingTransaction: any) => {
        waitingTXExecutionDisclosure.onOpen();
      },
      (pendingTransaction: any) => {
        waitingTXExecutionDisclosure.onClose();
        endTXCallback();
      },
      () => waitingTXValidationDisclosure.onOpen(),
      () => waitingTXValidationDisclosure.onClose()
    );
  };

  let voteTypeString =
    voteType == 0
      ? "Validation de l'étape en cours"
      : voteType == 1
      ? "Demande de fonds pour l'étape en cours"
      : "Annulation du projet et redistribution des fonds aux financers";

  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered size="xl">
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Voter</ModalHeader>

        <ModalBody>
          <Text mt="20px" align="center">
            Un vote est actuellement en vote, dont le sujet est le suivant : &apos;{voteTypeString}&apos;
          </Text>
          <Text align="center">Veuillez choisir si vous être pour ou contre cette motion</Text>
        </ModalBody>
        <ModalFooter>
          <Flex justify="space-between" width="100%">
            <Button colorScheme="blue" mr={3} onClick={onClose}>
              Annuler
            </Button>
            <Flex justify="end">
              <Button colorScheme="red" onClick={() => handleSubmit(false)}>
                Contre
              </Button>
              <Button colorScheme="green" onClick={() => handleSubmit(true)} ml="10px">
                Pour
              </Button>
            </Flex>
          </Flex>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
};
