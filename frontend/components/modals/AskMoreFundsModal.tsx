import { useState } from "react";
import {
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

export const AskMoreFundsModal = ({
  isOpen,
  onClose,
  maxAmountAvailable,
  projectAddress,
  waitingTXValidationDisclosure,
  waitingTXExecutionDisclosure,
  endTXCallback,
}: any) => {
  const [amount, setAmount] = useState("");
  const toast = useToast();

  const handleAmountChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setAmount(value);
  };

  const handleSubmit = async () => {
    const value = parseInt(amount, 10);
    if (!Number.isInteger(value) || value <= 999 || value > maxAmountAvailable || amount.includes(".") || amount.includes(",")) {
      toast({
        title: "Erreur de saisie",
        description: "Veuillez entrer un montant entier positif, de minimum 1000 Wei, et inférieur à " + maxAmountAvailable + ".",
        status: "error",
        duration: 5000,
        isClosable: true,
      });
    } else {
      onClose();
      await callWriteMethod(
        BlockFundingProjectFunctions.askForMoreFunds,
        [],
        BigInt(amount),
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
    }
  };

  return (
    <Modal onClose={onClose} isOpen={isOpen} isCentered size="xl">
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Demander plus de fonds</ModalHeader>
        <ModalCloseButton />

        <ModalBody>
          <Text>Félicitations, Vous avez décidé de participer à un projet d'avenir !</Text>
          <br />
          <Text></Text>
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
