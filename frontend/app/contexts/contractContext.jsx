import { createContext, useContext, useState } from "react";
import { VotingFunctions, VotingEvents, callReadMethod, callWriteMethod, watchEvent, getOldsEvents } from "@/app/js/wagmiWrapper.js";
import { useAccount } from "wagmi";
import useToast from "@/app/hooks/useToast";

const ContractContext = createContext();

export const VotingWorkflowStatus = {
  registeringVoters: 0,
  proposalsRegistrationStarted: 1,
  proposalsRegistrationEnded: 2,
  votingSessionStarted: 3,
  votingSessionEnded: 4,
  votesTallied: 5,
};

class Proposal {
  constructor(id, description, voteCount) {
    this.id = id;
    this.description = description;
    this.voteCount = voteCount;
  }
}

export class Event {
  constructor(timestamp, date, functionName, argument) {
    this.timestamp = timestamp;
    this.date = date;
    this.functionName = functionName;
    this.argument = argument;
  }
}

let voterRegisteredEvents = [],
  workflowStatusChangeEvents = [],
  proposalRegisteredEvents = [],
  votesEvents = [],
  events = [];
let initContractLock = false,
  initWithVoterCallsLoaded = false;
let proposalsLock = new Map();
let votersLock = new Map();

export const getEvents = () => {
  return events.sort((a, b) => {
    return a.timestamp < b.timestamp ? 1 : a.timestamp > b.timestamp ? -1 : 0;
  });
};

export const addEvent = (eventName, argument) => {
  events.push(new Event(Date.now(), getReadableDate(), eventName, argument));
};

export const ContractContextProvider = ({ children }) => {
  let [workflowStatus, setWorkflowStatus] = useState(VotingWorkflowStatus.registeringVoters);
  let [proposals, setProposals] = useState([]);
  let [voters, setVoters] = useState([]);
  let [isLoadingProposals, setIsLoadingProposals] = useState(false);
  let [initContractDone, setInitContractDone] = useState(false);
  let [isChangingStatus, setIsChangingStatus] = useState(false);
  let [waitingTransactionValidation, setIsWaitingTransactionValidation] = useState(false);
  const toast = useToast();
  let { address } = useAccount();

  const initContractContext = async () => {
    // Ensure that we init only once (because takes time & don't want duplicate watchers)
    if (!initContractLock) {
      initContractLock = true;

      // We get the contract status with a call for the first time, then use a watch to handle all new changes on that value
      const currentStatus = await callReadMethod(VotingFunctions.workflowStatus, 0);
      setWorkflowStatus(Object.keys(VotingWorkflowStatus).find((key) => VotingWorkflowStatus[key] === currentStatus));

      [voterRegisteredEvents, workflowStatusChangeEvents, proposalRegisteredEvents, votesEvents] = await getOldsEvents();

      // We get the already registered voters one, then watch new additions with events
      const pastVoters = voterRegisteredEvents.map((event) => event.args.voterAddress);
      setVoters(pastVoters);

      watchEvent(VotingEvents.workflowStatusChange, (event) => {
        const newStatus = event[0].args.newStatus;

        const status = Object.keys(VotingWorkflowStatus).find((key) => VotingWorkflowStatus[key] === newStatus);
        setWorkflowStatus(status);
      });

      watchEvent(VotingEvents.voterRegistered, async (event) => {
        const newVoter = event[0].args.voterAddress;

        if (voters.find((voter) => voter === newVoter) === undefined && !votersLock.get(newVoter)) {
          votersLock.set(newVoter, true);
          setVoters((voters) => [...voters, newVoter]);
          votersLock.set(newVoter, false);
        }
      });

      watchEvent(VotingEvents.proposalRegistered, async (event) => {
        const newProposalId = event[0].args.proposalId;

        if (proposals.find((proposal) => proposal.id === newProposalId) === undefined && !proposalsLock.get(newProposalId)) {
          proposalsLock.set(newProposalId, true);
          try {
            const newProposal = await callReadMethod(VotingFunctions.getOneProposal, address, [newProposalId]);
            addEvent(VotingEvents.proposalRegistered, newProposal.description);
            setProposals((proposals) => [...proposals, new Proposal(newProposalId, newProposal.description, newProposal.voteCount)]);
          } catch (e) {
            console.log("Received a proposal event when the connected user didn't had right to see it, ignoring it");
          }
          proposalsLock.set(newProposalId, false);
        }
      });
    }

    watchEvent(VotingEvents.voted, async (event) => {
      const voterAddress = event[0].args.voter;
      const votedId = event[0].args.proposalId;

      addEvent(VotingEvents.voted, voterAddress + "," + votedId);
    });
    setInitContractDone(true);
  };

  const initContractContextWithVoterCalls = async () => {
    if (initContractDone && !initWithVoterCallsLoaded) {
      try {
        setIsLoadingProposals((oldValue) => true);
        await prepareProposalEvents(proposalRegisteredEvents.map((proposal) => proposal.args.proposalId));
        initWithVoterCallsLoaded = true;
      } finally {
        setIsLoadingProposals((oldValue) => false);
      }
    }
  };

  async function prepareProposalEvents(proposalEventsIds) {
    for (let i = 0; i < proposalEventsIds.length; i++) {
      const curId = proposalEventsIds[i];

      if (proposals.find((proposal) => proposal.id === curId) === undefined && !proposalsLock.get(curId)) {
        proposalsLock.set(curId, true);
        const newProposal = await callReadMethod(VotingFunctions.getOneProposal, address, [curId]);
        setProposals((proposals) => [...proposals, new Proposal(curId, newProposal.description, newProposal.voteCount)]);
        proposalsLock.set(curId, false);
      }
    }
  }

  async function changeToGivenStatus(workflowStatusFunction, successMessage) {
    await callWriteMethod(
      workflowStatusFunction,
      [],
      () => {
        addEvent(VotingEvents.workflowStatusChange, workflowStatusFunction);
        toast.showSuccess(successMessage);
        setIsChangingStatus((oldValue) => false);
      },
      (error) => toast.showError(error.message),
      (tx) => {},
      (tx) => {},
      () => {
        setIsWaitingTransactionValidation((oldValue) => true);
      },
      () => {
        setIsWaitingTransactionValidation((oldValue) => false);
        setIsChangingStatus((oldValue) => true);
      }
    );
  }

  const value = {
    initContractContext,
    initContractContextWithVoterCalls,
    initContractDone,
    isLoadingProposals,
    workflowStatus,
    proposals,
    voters,
    changeToGivenStatus,
    isChangingStatus,
    setIsChangingStatus,
    waitingTransactionValidation,
    setIsWaitingTransactionValidation,
  };

  return <ContractContext.Provider value={value}>{children}</ContractContext.Provider>;
};

export const useContractContext = () => useContext(ContractContext);
