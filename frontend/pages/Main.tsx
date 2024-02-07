import { Container } from "@chakra-ui/react";

import { HomePage } from "@/pages/HomePage";

const Main = () => {
  return (
    <>
      <Container my="4rem" maxW="120ch">
        <HomePage />
      </Container>
    </>
  );
};

export default Main;
