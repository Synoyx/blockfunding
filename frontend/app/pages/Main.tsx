import { Container } from "@chakra-ui/react";

import { HomePage } from "@/app/pages/homePage/HomePage.tsx";

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
