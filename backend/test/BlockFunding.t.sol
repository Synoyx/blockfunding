// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";

import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "./helpers/ClonesHelper.h.sol";

contract BlockFundingTest is Test {
    BlockFunding blockFunding;

    function setUp() external {
        blockFunding = new BlockFunding();
    }

    function test_blockfundingProjectCloning() external {
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(blockFunding.getProjectsAddresses().length, 0, "Projects array isn't empty when BlockFunding contract is initialized");

        ClonesHelper.createMockContract(address(blockFunding));

        assertEq(blockFunding.getProjectsAddresses().length, 1, "The project clone hasn't been added to list");

        BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));

        assertEq(Strings.compare(clonedProject.getName(), ClonesHelper.name), true, "Values in cloned contract seems incorrect");
    }

    function test_blockfundingMultipleProjectsCloning() external {
        assertEq(blockFunding.getProjectsAddresses().length, 0, "Projects array isn't empty when BlockFunding contract is initialized");

        for (uint i; i < 100; i++) {
            ClonesHelper.createMockContract(address(blockFunding));
        }

        assertEq(blockFunding.getProjectsAddresses().length, 100, "Projects array isn't empty when BlockFunding contract is initialized");

    }

}