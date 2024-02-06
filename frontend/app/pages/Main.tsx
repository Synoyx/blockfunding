import { Container } from "@chakra-ui/react";

import { HomePage } from "@/app/pages/homePage/HomePage";
import CreateProject from "@/app/pages/createProject/CreateProject.tsx";

const Main = () => {
  return (
    <>
      <Container my="4rem" maxW="120ch">
        <CreateProject/>
      </Container>
    </>
  );
};

export default Main;
