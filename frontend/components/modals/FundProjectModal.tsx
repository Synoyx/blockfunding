import { useState } from "react";
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
  Text,
  InputGroup,
  InputRightAddon,
  Input,
  useToast,
} from "@chakra-ui/react";

import { callWriteMethod } from "@/ts/wagmiWrapper";
import { BlockFundingProjectFunctions } from "@/ts/objects/BlockFundingProjectContract";

export const FundProjectModal = ({ isOpen, onClose, projectName, projectAddress, waitingTXValidationDisclosure }: any) => {
  const [amount, setAmount] = useState("");
  const toast = useToast();

  const handleAmountChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setAmount(value);
  };

  /*

  contractToCallAddress: any = "",
  endTXCallback = () => {},
  errorCallback: any = (e: any) => {
    throw e;
  },
  handleNewPendingTransaction = (pendingTransaction: any) => {},
  handlePendingTransactionDone = (pendingTransaction: any) => {},
  handleWaitingForMetamaskEvent = () => {},
  handleWaitingForMetamaskEndEvent = () => {}
  */

  const handleSubmit = async () => {
    const value = parseInt(amount, 10);
    if (!Number.isInteger(value) || value <= 999 || amount.includes(".") || amount.includes(",")) {
      toast({
        title: "Erreur de saisie",
        description: "Veuillez entrer un montant entier positif, de minimum 1000 Wei.",
        status: "error",
        duration: 5000,
        isClosable: true,
      });
    } else {
      onClose();
      await callWriteMethod(
        BlockFundingProjectFunctions.fundProject,
        [],
        BigInt(amount),
        projectAddress,
        () => {},
        (e: any) => {
          throw e;
        },
        () => {},
        () => {},
        () => waitingTXValidationDisclosure.onOpen(),
        () => waitingTXValidationDisclosure.onClose()
      );
    }
  };

  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered size="xl">
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Participer au projet</ModalHeader>
        <ModalCloseButton />

        <ModalBody>
          <Text>Félicitations, Vous avez décidé de participer à un projet d'avenir !</Text>
          <br />
          <Text>
            Veuillez saisir le montant de votre participation et cliquer sur le bouton valider pour devenir un financer et participer à la
            communauté du projet {projectName}
          </Text>
          <InputGroup mt={4}>
            <Input placeholder="Montant en Wei" type="number" min="0" step="1" value={amount} onChange={handleAmountChange} />
            <InputRightAddon children="Wei" />
          </InputGroup>
        </ModalBody>
        <ModalFooter>
          <Button colorScheme="blue" mr={3} onClick={onClose}>
            Annuler
          </Button>
          <Button colorScheme="green" onClick={handleSubmit}>
            Valider
          </Button>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
};
