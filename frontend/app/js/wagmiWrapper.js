"use client";

import { prepareWriteContract, writeContract, readContract, waitForTransaction, watchContractEvent, getPublicClient } from "@wagmi/core";
import { contractAddress, abi, deployBlockNumber } from "./constants";
import { parseAbiItem, decodeEventLog } from "viem";

export const VotingFunctions = {
  owner: "owner", // Returns address
  workflowStatus: "workflowStatus", // Returns string ?
  winningProposalID: "winningProposalID", // Returns int
  getVoter: "getVoter", // Only for voters, takes address as parameter
  getOneProposal: "getOneProposal", // Only for voters, takes proposalId as parameter
  addVoter: "addVoter", // Only for owner, takes address as parameter
  addProposal: "addProposal", // Only for voters, takes string as parameter
  setVote: "setVote", // Only for voters, takes proposalId as parameter
  startProposalsRegistering: "startProposalsRegistering", // Only for owner
  endProposalsRegistering: "endProposalsRegistering", // Only for owner
  startVotingSession: "startVotingSession", // Only for owner
  endVotingSession: "endVotingSession", // Only for owner
  tallyVotes: "tallyVotes", // Only for owner
};

export const VotingEvents = {
  voterRegistered: "VoterRegistered",
  workflowStatusChange: "WorkflowStatusChange",
  proposalRegistered: "ProposalRegistered",
  voted: "Voted",
};

/**
 * Method used to call a "read" method.
 * In the case of voting contract, you can use owner, workflowStatus, winningProposalId, getVoter and getOneProposal.
 * For the last ones, remember to give the appropriated arguments.
 */
export async function callReadMethod(
  VotingFunction,
  account,
  args = [],
  endTXCallback = () => {},
  errorCallback = (e) => {
    throw e;
  }
) {
  try {
    const data = await readContract({
      address: contractAddress,
      account: account,
      abi: abi,
      functionName: VotingFunctions[VotingFunction],
      args: args,
    });

    endTXCallback();

    return data;
  } catch (e) {
    errorCallback(e);
  }
}
/**
 * Method used to call a "write" method.
 * In the case of voting contract, you can use addVoter, addProposal, setVote, tallyVotes, and all workflowsStatus change methods.
 * For the first ones, remember to give the appropriated arguments.
 *
 * You can use endTXCallback to call a method once the block containing the method has been validated (like a toast for example)
 */
export async function callWriteMethod(
  VotingFunction,
  args = [],
  endTXCallback = () => {},
  errorCallback = (e) => {
    throw e;
  },
  handleNewPendingTransaction = (pendingTransaction) => {},
  handlePendingTransactionDone = (pendingTransaction) => {},
  handleWaitingForMetamaskEvent = () => {},
  handleWaitingForMetamaskEndEvent = () => {}
) {
  try {
    const config = await prepareWriteContract({
      address: contractAddress,
      abi: abi,
      functionName: VotingFunction,
      args: args,
    });
    handleWaitingForMetamaskEvent();
    const { hash } = await writeContract(config);
    handleWaitingForMetamaskEndEvent();

    const pendingTX = {
      hash: hash,
      address: contractAddress,
      functionName: VotingFunction,
      args: args,
    };

    handleNewPendingTransaction(pendingTX);

    await waitForTransaction({ hash: hash });

    handlePendingTransactionDone(pendingTX);

    endTXCallback();
  } catch (e) {
    handleWaitingForMetamaskEndEvent();
    errorCallback(e);
  }
}

export function watchEvent(
  VotingEvent,
  callback = (log) => {},
  errorCallback = (e) => {
    throw e;
  }
) {
  try {
    watchContractEvent(
      {
        address: contractAddress,
        abi: abi,
        eventName: VotingEvent,
      },
      callback
    );
  } catch (e) {
    errorCallback(e);
  }
}

export async function getOldsEvents() {
  let events = await getPublicClient().getLogs({
    address: contractAddress,
    fromBlock: deployBlockNumber,
  });

  let voterRegisteredEvents = [];
  let workflowStatusChangeEvents = [];
  let proposalRegisteredEvents = [];
  let votesEvents = [];

  for (let i = 0; i < events.length; i++) {
    try {
      const eventDecoded = decodeEventLog({
        abi: abi,
        data: events[i].data,
        topics: events[i].topics,
      });

      switch (eventDecoded.eventName) {
        case VotingEvents.voterRegistered:
          voterRegisteredEvents.push(eventDecoded);
          break;
        case VotingEvents.workflowStatusChange:
          workflowStatusChangeEvents.push(eventDecoded);
          break;
        case VotingEvents.proposalRegistered:
          proposalRegisteredEvents.push(eventDecoded);
          break;
        case VotingEvents.voterRegistered:
          votesEvents.push(eventDecoded);
          break;
      }
    } catch (e) {}
  }

  return [voterRegisteredEvents, workflowStatusChangeEvents, proposalRegisteredEvents, votesEvents];
}
