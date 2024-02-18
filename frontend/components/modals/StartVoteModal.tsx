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

export const StartVoteModal = ({
  isOpen,
  onClose,
  voteType,
  projectAddress,
  waitingTXValidationDisclosure,
  waitingTXExecutionDisclosure,
  endTXCallback,
}: any) => {
  const handleSubmit = async () => {
    onClose();
    await callWriteMethod(
      BlockFundingProjectFunctions.startVote,
      ["" + voteType],
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
        <ModalHeader>Démarrer une session de vote</ModalHeader>

        <ModalBody>
          <Text mt="20px" align="center">
            Chaque session de vote dure jusqu&apos;à ce que l&apos;ensemble des participants se soient exprimés, ou que trois jours se sont
            écoulés après le début du vote.
          </Text>
          <Text align="center">Êtes-vous sûr de vouloir débuter un vote &apos;{voteTypeString}&apos; ?</Text>
        </ModalBody>
        <ModalFooter>
          <Button colorScheme="blue" mr={3} onClick={onClose}>
            Annuler
          </Button>
          <Button colorScheme="green" onClick={handleSubmit}>
            Lancer le vote
          </Button>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
};
