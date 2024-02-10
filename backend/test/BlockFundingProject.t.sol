// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import "forge-std/Test.sol";

import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "./helpers/ClonesHelper.h.sol";

contract BlockFundingProjectTest is Test {
    BlockFunding blockFunding;

    function setUp() external {
        blockFunding = new BlockFunding();
    }

    /**
    * @notice Check that you can't initialize twice the contract
    */
    function test_initializeTwice() external {
        ClonesHelper.createMockContract(address(blockFunding));

        BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));

        vm.expectRevert(abi.encodeWithSelector(Initializable.InvalidInitialization.selector));
        clonedProject.initialize(msg.sender);
    }
}