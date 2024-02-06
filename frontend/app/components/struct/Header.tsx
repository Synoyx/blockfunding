"use client";

import { useAccount } from "wagmi";

import { Flex, Text, Menu, MenuButton, MenuList, Image } from "@chakra-ui/react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { BellIcon } from "@chakra-ui/icons";
import Link from "next/link";

import logo from "@/app/assets/images/logo.png";
const Header = () => {
  const { isConnected } = useAccount();

  return (
    <Flex
      px="2rem"
      py="1rem"
      justifyContent="space-between"
      alignItems="center"
      width="100%"
      backgroundColor="#05045E"
      pos="fixed"
      top="0"
      zIndex={2}
    >
      <Flex alignItems="center">
        <Image src={logo.src} maxHeight="50px" alt="BlockFunding logo" />
        <Text fontSize={18} marginLeft="15px" fontWeight={700} color="#fff8e3">
          Blockfunding
        </Text>
      </Flex>

      <Text color="#fff8e3">{isConnected && `You are connected as TODO:SETUSERROLE`}</Text>
      <Flex alignItems="inherit">
        {isConnected ? (
          <Flex mr="1rem">
            <Menu>
              <Link href="/CreateProject" passHref>
                <MenuButton>Créer un Nouveau Projet</MenuButton>
              </Link>
              <MenuButton>
                <BellIcon color="white" boxSize={6} />
              </MenuButton>
              <MenuList overflowY="scroll"></MenuList>
            </Menu>
          </Flex>
        ) : (
          <></>
        )}
        <span>
          <ConnectButton />
        </span>
      </Flex>
    </Flex>
  );
};

export default Header;
