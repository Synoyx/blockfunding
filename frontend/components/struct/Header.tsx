"use client";

import { useAccount } from "wagmi";
import { useRouter } from "next/navigation";
import Link from "next/link";

import { Flex, Text, Menu, MenuButton, MenuList, Image, Stack, MenuItem } from "@chakra-ui/react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { BellIcon } from "@chakra-ui/icons";

import logo from "@/assets/images/logo.png";

export const Header = () => {
  const router = useRouter();
  const { isConnected } = useAccount();

  return (
    <Flex px="2rem" py="1rem" justifyContent="space-between" alignItems="center" backgroundColor="#05045E">
      <Link href="/">
        <Flex alignItems="center">
          <Image src={logo.src} maxHeight="50px" alt="BlockFunding logo" />
          <Text fontSize={18} marginLeft="15px" fontWeight={700} color="#fff8e3">
            Blockfunding
          </Text>
        </Flex>
      </Link>

      <Flex alignItems="inherit">
        {isConnected ? (
          <Flex mr="1rem">
            <Menu>
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
