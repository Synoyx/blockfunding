"use client";

import { useSearchParams } from "next/navigation";
import Link from "next/link";

import { Box } from "@chakra-ui/react";

const ProjectDetails = () => {
  const params = useSearchParams();
  const projectId = params!.get("id");

  return <Box p={8}>Manage project here ...</Box>;
};

export default ProjectDetails;
