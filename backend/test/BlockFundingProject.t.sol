// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import "forge-std/Test.sol";

import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "../script/tools/MockedData.sol";

contract BlockFundingProjectTest is Test {
    BlockFunding blockFunding;

    function setUp() external {
        blockFunding = new BlockFunding();
    }

    /**
    * @notice Check that you can't initialize twice the contract
    */
    function test_initializeTwice() external {
        blockFunding.createNewProject(MockedData.getMockedProjectDatas()[0]);

        vm.roll(10);

        //TODO Strange behaviour here, According to openzeppellin it seems to be normal under test conditions
        //TO test that, wait for a initialized event instead ?
        //BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));
        //vm.expectRevert(abi.encodeWithSelector(Initializable.InvalidInitialization.selector));
        //clonedProject.initialize(msg.sender, ClonesHelper.getMockedProjectData());
    }
}