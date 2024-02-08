"use client";

import { Flex, Text } from "@chakra-ui/react";

export const Footer = () => {
  return (
    <Flex p="1rem" justifyContent="center" alignItems="center" width="100%" pos="fixed" bottom="0" zIndex={2} bg="#fff8e3">
      <Text fontSize={14} fontWeight="600">
        Built by Julien P. for Alyra School
      </Text>
    </Flex>
  );
};
