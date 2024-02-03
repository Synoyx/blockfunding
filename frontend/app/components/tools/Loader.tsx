import { Spinner, Flex } from "@chakra-ui/react";

const Loader = () => (
  <Flex justifyContent="center" pt="40vh">
    <Spinner color="#05045E" size="xl" />
  </Flex>
);

export default Loader;
