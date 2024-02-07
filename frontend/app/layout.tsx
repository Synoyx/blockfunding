"use client";

import { ChakraProvider } from "@chakra-ui/react";
import { extendTheme } from "@chakra-ui/react";
import "@rainbow-me/rainbowkit/styles.css";

// Importing rainbowkit for connecting wallet from different sources ...
import { getDefaultWallets, RainbowKitProvider, lightTheme } from "@rainbow-me/rainbowkit"; //getDefaultWallets,
import { configureChains, createConfig, WagmiConfig } from "wagmi";
import { sepolia, hardhat } from "wagmi/chains";
import { publicProvider } from "wagmi/providers/public";
import { ReactNode } from "react";

import { BlockFundingContractContextProvider } from "@/contexts/blockFundingContractContext";

const { chains, publicClient } = configureChains([sepolia, hardhat], [publicProvider(), publicProvider()]);

const { connectors } = getDefaultWallets({
  appName: "Voting contract app",
  projectId: "fba081ed7d956cedcbd5453c3fb61423", // We let it clear, as it is easy to get it by looking on network exchanges of the DApp
  chains,
});

const wagmiConfig = createConfig({
  autoConnect: false,
  connectors,
  publicClient,
});

//CHAKRA UI THEME
const theme = extendTheme({
  styles: {
    global: {
      body: {
        bg: "#fff8e3",
        color: "#05045E",
      },
    },
  },
});

export default function RootLayout({ children }: any) {
  return (
    <html lang="fr">
      <body>
        <ChakraProvider theme={theme}>
          <WagmiConfig config={wagmiConfig}>
            <RainbowKitProvider
              chains={chains}
              theme={lightTheme({
                accentColor: "#fff8e3",
                accentColorForeground: "#05045E",
              })}
            >
              <BlockFundingContractContextProvider>{children}</BlockFundingContractContextProvider>
            </RainbowKitProvider>
          </WagmiConfig>
        </ChakraProvider>
      </body>
    </html>
  );
}
