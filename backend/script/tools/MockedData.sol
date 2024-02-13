// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../../src/BlockFunding.sol";
import "../../src/BlockFundingProject.sol";

library MockedData {
    address public constant targetWallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint32 public constant campaignStartingDateTimestamp = 1707005560;
    uint32 public constant campaignEndingDateTimestamp = 1709507562;
    uint32 public constant estimatedProjectReleaseDateTimestamp = 1727993562;

    function getMockedProjectDatas() public view returns(BlockFundingProject.ProjectData[] memory) {
        BlockFundingProject.ProjectData[] memory mockedData = new BlockFundingProject.ProjectData[](3);

        mockedData[0] = BlockFundingProject.ProjectData(
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.art,
            "Projet Alpha",
            "Innovation en Art",
            "Exploration des frontieres numeriques dans l'art contemporain.",
            "https://cdn2.f-cdn.com/contestentries/1262273/26237065/5a8d53d99fc82_thumb900.jpg",
            getMockedTeamMembers(),
            getMockedProjectSteps());

        //TODO handle accents in strings

        mockedData[1] = BlockFundingProject.ProjectData(
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.technology,
            "Eco drive",
            "Revolution automobile",
            "Une approche durable de la mobilite urbaine.",
            "https://www.shutterstock.com/image-photo/black-modern-car-closeup-on-600nw-2139196215.jpg",
            getMockedTeamMembers(),
            getMockedProjectSteps());

        mockedData[2] = BlockFundingProject.ProjectData(
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.art,
            "Tech innovate",
            "Avancee en informatique",
            "Developpement d'un nouveau systeme d'exploration base sur la securite.",
            "https://i.pinimg.com/736x/d2/dc/d4/d2dcd4e515f401cc834e6ae5ba0dbd1a.jpg",
            getMockedTeamMembers(),
            getMockedProjectSteps());

        return mockedData;
    }

    function getMockedTeamMembers() internal pure returns(BlockFundingProject.TeamMember[] memory) {
        BlockFundingProject.TeamMember[] memory mockedData = new BlockFundingProject.TeamMember[](3);

        // Premier membre de l'équipe
        mockedData[0] = BlockFundingProject.TeamMember({
            firstName: "Alice",
            lastName: "Doe",
            description: "Lead Developer with extensive experience in blockchain technology.",
            photoLink: "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=1200",
            role: "Lead Developer",
            walletAddress: 0x0B89257b0ee39f7B60E97b1304fd8a4fC031B395 
        });

        // Deuxième membre de l'équipe
        mockedData[1] = BlockFundingProject.TeamMember({
            firstName: "Bob",
            lastName: "Smith",
            description: "Project Manager with a decade of industry experience.",
            photoLink: "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=1200",
            role: "Project Manager",
            walletAddress: 0x01beB3F1727Ca50a55ee8875c8178b59362E5E21
        });

        // Troisième membre de l'équipe
        mockedData[2] = BlockFundingProject.TeamMember({
            firstName: "Charlie",
            lastName: "Brown",
            description: "Creative Director with a keen eye for design.",
            photoLink: "https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=1200",
            role: "Creative Director",
            walletAddress: 0x9cc62Fa77F34b7EB235cBA358E6177e8868512c3
        });

        return mockedData;
    }

    function getMockedProjectSteps() internal pure returns(BlockFundingProject.ProjectStep[] memory) {
        BlockFundingProject.ProjectStep[] memory mockedData = new BlockFundingProject.ProjectStep[](5);

        mockedData[0] = BlockFundingProject.ProjectStep({
            name: "Conceptualization",
            description: "Defining the project scope and its feasibility.",
            amountNeeded: 1000000,
            amountFunded: 500000,
            isFunded: true,
            orderNumber: 1,
            hasBeenValidated: false
        });

        mockedData[1] = BlockFundingProject.ProjectStep({
            name: "Design",
            description: "Creating detailed designs and specifications.",
            amountNeeded: 2000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 2,
            hasBeenValidated: false
        });

        mockedData[2] = BlockFundingProject.ProjectStep({
            name: "Development",
            description: "Development phase to build and test the project.",
            amountNeeded: 3000000,
            amountFunded: 1500000,
            isFunded: false,
            orderNumber: 3,
            hasBeenValidated: false
        });

        mockedData[3] = BlockFundingProject.ProjectStep({
            name: "Testing",
            description: "Rigorous testing to ensure quality and performance.",
            amountNeeded: 500000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 4,
            hasBeenValidated: false
        });

        mockedData[4] = BlockFundingProject.ProjectStep({
            name: "Launch",
            description: "Official launch of the project to the public.",
            amountNeeded: 1000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 5,
            hasBeenValidated: false
        });

        return mockedData;
    }
}