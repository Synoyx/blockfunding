"use client";

import { ChakraProvider } from "@chakra-ui/react";
import { extendTheme } from "@chakra-ui/react";
import "@rainbow-me/rainbowkit/styles.css";

import { Flex } from "@chakra-ui/react";

// Importing rainbowkit for connecting wallet from different sources ...
import { RainbowKitProvider, lightTheme } from "@rainbow-me/rainbowkit"; //getDefaultWallets,
import { WagmiConfig } from "wagmi";

import { BlockFundingContractContextProvider } from "@/contexts/blockFundingContractContext";
import { wagmiConfig, chains } from "@/ts/wagmiWrapper";

import { ContextsLoader } from "@/components/struct/ContextsLoader";
import { Header } from "@/components/struct/Header";
import { Footer } from "@/components/struct/Footer";

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

export default function Layout({ children }: any) {
  return (
    <>
      <ChakraProvider theme={theme}>
        <WagmiConfig config={wagmiConfig}>
          <RainbowKitProvider
            chains={chains}
            theme={lightTheme({
              accentColor: "#fff8e3",
              accentColorForeground: "#05045E",
            })}
          >
            <BlockFundingContractContextProvider>
              <ContextsLoader>
                <main>
                  <Flex direction="column" height="100vh" justifyContent="space-between">
                    <Header />
                    <Flex justifyContent="center">{children}</Flex>
                    <Footer />
                  </Flex>
                </main>
              </ContextsLoader>
            </BlockFundingContractContextProvider>
          </RainbowKitProvider>
        </WagmiConfig>
      </ChakraProvider>
    </>
  );
}
