// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";

import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "./helpers/ClonesHelper.h.sol";

contract BlockFundingTest is Test {
    address public constant owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    string public constant name = "MockedContract";
    string public constant subtitle = "This is a mocked contract for testing purposes";
    string public constant description = "This is the description of the contract created for testing purposes";
    address public constant targetWallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint32 public constant campaignStartingDateTimestamp = 1707005560;
    uint32 public constant campaignEndingDateTimestamp = 1709507562;
    uint32 public constant estimatedProjectReleaseDateTimestamp = 1727993562;
    BlockFunding.ProjectCategory public constant projectCategory = BlockFunding.ProjectCategory.art;
    uint96 public constant fundingRequested = 1000000000000000000;

    BlockFunding blockFunding;

    function setUp() external {
        blockFunding = new BlockFunding();
    }

    function test_blockfundingProjectCloning() external {
        assertEq(blockFunding.getProjectsAddresses().length, 0, "Projects array isn't empty when BlockFunding contract is initialized");

        ClonesHelper.createMockContract(address(blockFunding));

        assertEq(blockFunding.getProjectsAddresses().length, 1, "The project clone hasn't been added to list");

        BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));

        assertEq(Strings.compare(clonedProject.getName(), ClonesHelper.name), true, "Values in cloned contract seems incorrect");
    }

    function test_transferOwnershipOnCreation() external {
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        
        blockFunding.createNewContract(
            [name,
            subtitle,
            description],
            new string[](3),
            [uint(campaignStartingDateTimestamp),
            uint(campaignEndingDateTimestamp),
            uint(estimatedProjectReleaseDateTimestamp),
            uint(fundingRequested)],
            targetWallet,
            BlockFunding.ProjectCategory.art
        );

        BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));

        assertEq(clonedProject.getOwner(), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, "Address not good !");
    }

    function test_blockfundingMultipleProjectsCloning() external {
        assertEq(blockFunding.getProjectsAddresses().length, 0, "Projects array isn't empty when BlockFunding contract is initialized");

        for (uint i; i < 100; i++) {
            ClonesHelper.createMockContract(address(blockFunding));
        }

        assertEq(blockFunding.getProjectsAddresses().length, 100, "Projects array isn't empty when BlockFunding contract is initialized");

    }

}