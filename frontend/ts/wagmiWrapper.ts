"use client";

import { prepareWriteContract, writeContract, readContract, waitForTransaction, watchContractEvent, getPublicClient } from "@wagmi/core";
import { publicProvider } from "wagmi/providers/public";
import { configureChains, createConfig } from "wagmi";
import { sepolia, hardhat } from "wagmi/chains";

import { getDefaultWallets } from "@rainbow-me/rainbowkit";

import { BlockFundingProjectFunctions } from "@/ts/objects/BlockFundingProjectContract";
import { BlockFundingFunctions } from "@/ts/objects/BlockFundingContract";
import { contractAddress, blockFundingAbi, blockFundingProjectAbi, deployBlockNumber } from "@/ts/constants";

export const { chains, publicClient } = configureChains([sepolia, hardhat], [publicProvider(), publicProvider()]);

const { connectors } = getDefaultWallets({
  appName: "BlockFunding",
  projectId: "fba081ed7d956cedcbd5453c3fb61423", // We let it clear, as it is easy to get it by looking on network exchanges of the DApp
  chains,
});

export const wagmiConfig = createConfig({
  autoConnect: false,
  connectors,
  publicClient,
});

/**
 * Method used to call a "read" method.
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
    const temp: any = functionToCall;
    const abi: any = Object.values(BlockFundingFunctions).includes(temp) ? blockFundingAbi : blockFundingProjectAbi;
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
 *
 * You can use endTXCallback to call a method once the block containing the method has been validated (like a toast for example)
 */
export async function callWriteMethod(
  functionToCall: BlockFundingFunctions | BlockFundingProjectFunctions,
  args: any[] = [],
  payableValue: bigint = 0n,
  contractToCallAddress: any = "",
  endTXCallback = () => {},
  errorCallback: any = (e: any) => {
    throw e;
  },
  handleNewPendingTransaction = (pendingTransaction: any) => {},
  handlePendingTransactionDone = (pendingTransaction: any) => {},
  handleWaitingForMetamaskEvent = () => {},
  handleWaitingForMetamaskEndEvent = () => {}
) {
  try {
    const temp: any = functionToCall;
    const abi: any = Object.values(BlockFundingFunctions).includes(temp) ? blockFundingAbi : blockFundingProjectAbi;
    let config: any;
    if (payableValue > 0n) {
      config = await prepareWriteContract({
        address: contractToCallAddress === "" ? contractAddress : contractToCallAddress,
        abi: abi,
        functionName: functionToCall.valueOf(),
        args: args,
        value: payableValue,
      });
    } else {
      config = await prepareWriteContract({
        address: contractAddress,
        abi: abi,
        functionName: functionToCall.valueOf(),
        args: args,
      });
    }

    console.log(config);
    handleWaitingForMetamaskEvent();
    const { hash } = await writeContract(config);
    handleWaitingForMetamaskEndEvent();

    const pendingTX = {
      hash: hash,
      address: contractAddress,
      functionName: functionToCall.valueOf(),
      args: args,
    };

    //handleNewPendingTransaction(pendingTX);

    await waitForTransaction({ hash: hash });

    //handlePendingTransactionDone(pendingTX);

    endTXCallback();
  } catch (e) {
    handleWaitingForMetamaskEndEvent();
    errorCallback(e);
  }
}

export function watchEvent() {}
