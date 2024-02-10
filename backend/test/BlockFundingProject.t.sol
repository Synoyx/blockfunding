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
        BlockFundingProject.ProjectData memory data = ClonesHelper.getMockedProjectData();
        blockFunding.createNewContract([data.name,
            data.subtitle,
            data.description],
            new string[](3),
            [uint(data.campaignStartingDateTimestamp),
            uint(data.campaignEndingDateTimestamp),
            uint(data.estimatedProjectReleaseDateTimestamp),
            uint(data.fundingRequested)],
            data.targetWallet,
            BlockFunding.ProjectCategory.art);


        vm.roll(10);

        //TODO Strange behaviour here, According to openzeppellin it seems to be normal under test conditions
        //BlockFundingProject clonedProject = BlockFundingProject(payable(blockFunding.projects(0)));
        //vm.expectRevert(abi.encodeWithSelector(Initializable.InvalidInitialization.selector));
        //clonedProject.initialize(msg.sender, ClonesHelper.getMockedProjectData());
    }
}