"use client";

import { prepareWriteContract, writeContract, readContract, waitForTransaction, watchContractEvent, getPublicClient } from "@wagmi/core";

import { BlockFundingProjectFunctions } from "@/app/ts/objects/BlockFundingProjectContract";
import { BlockFundingFunctions } from "@/app/ts/objects/BlockFundingContract";
import { contractAddress, abi, deployBlockNumber } from "@/app/ts/constants";

/**
 * Method used to call a "read" method.
 * In the case of voting contract, you can use owner, workflowStatus, winningProposalId, getVoter and getOneProposal.
 * For the last ones, remember to give the appropriated arguments.
 */
export async function callReadMethod(
  functionToCall: BlockFundingFunctions | BlockFundingProjectFunctions,
  account: any,
  args = [],
  endTXCallback = () => {},
  errorCallback = (e: any) => {
    throw e;
  }
) {
  try {
    const data = await readContract({
      address: contractAddress,
      account: account,
      abi: abi,
      functionName: functionToCall.valueOf(),
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
  functionToCall: BlockFundingFunctions | BlockFundingProjectFunctions,
  args = [],
  endTXCallback = () => {},
  errorCallback = (e: any) => {
    throw e;
  },
  handleNewPendingTransaction = (pendingTransaction: any) => {},
  handlePendingTransactionDone = (pendingTransaction: any) => {},
  handleWaitingForMetamaskEvent = () => {},
  handleWaitingForMetamaskEndEvent = () => {}
) {
  try {
    const config = await prepareWriteContract({
      address: contractAddress,
      abi: abi,
      functionName: functionToCall.valueOf(),
      args: args,
    });
    handleWaitingForMetamaskEvent();
    const { hash } = await writeContract(config);
    handleWaitingForMetamaskEndEvent();

    const pendingTX = {
      hash: hash,
      address: contractAddress,
      functionName: functionToCall.valueOf(),
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

export function watchEvent() {}
/*
  VotingEvent,
  callback = (log) => {},
  errorCallback = (e: any) => {
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
  */
