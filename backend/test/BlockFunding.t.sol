// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";


import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "../script/tools/MockedData.sol";

contract BlockFundingTest is Test {
    BlockFunding blockFunding;

    function setUp() external {
        blockFunding = new BlockFunding();
    }

    function test_blockfundingProjectCloning() external {
        assertEq(blockFunding.getProjectsAddresses().length, 0, "Projects array isn't empty when BlockFunding project is initialized");

        blockFunding.createNewProject(MockedData.getMockedProjectDatas()[0]);

        assertEq(blockFunding.getProjectsAddresses().length, 1, "The project clone hasn't been added to list");

        BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));

        assertEq(Strings.compare(clonedProject.getName(), MockedData.getMockedProjectDatas()[0].name), true, "Values in cloned project seems incorrect");
    }

    function test_transferOwnershipOnCreation() external {
        vm.startPrank(MockedData.getMockedProjectDatas()[0].owner);
        
        blockFunding.createNewProject(MockedData.getMockedProjectDatas()[0]);

        BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));

        assertEq(clonedProject.getOwner(), MockedData.getMockedProjectDatas()[0].owner, "Address not good !");
    }

    function test_blockfundingMultipleProjectsCloning() external {
        assertEq(blockFunding.getProjectsAddresses().length, 0, "Projects array isn't empty when BlockFunding project is initialized");

        for (uint i; i < 100; i++) {
            blockFunding.createNewProject(MockedData.getMockedProjectDatas()[0]);
        }

        assertEq(blockFunding.getProjectsAddresses().length, 100, "Projects array isn't empty when BlockFunding project is initialized");
    }

    function test_clonesAreDeployedToDifferentAddresses() external {
        address[] memory clonesAddresses = new address[](3);

        for (uint i; i < 3; i++) {
            blockFunding.createNewProject(MockedData.getMockedProjectDatas()[i]);
            clonesAddresses[i] = blockFunding.projects(i);
            console.log(blockFunding.projects(i));

            assertEq(arrayContainsOnlyOnce(blockFunding.projects(i), clonesAddresses), true, "Clones have the same addresses !");
        }
    }

    function arrayContainsOnlyOnce(address value, address[] memory array) internal pure returns(bool) {
        uint count;

        for (uint e; e < array.length; e++) { 
            if (array[e] == value) {
                count++;
            }
        }

        return count == 1;
    }
}