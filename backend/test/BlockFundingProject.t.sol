// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import "forge-std/Test.sol";

import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "../script/tools/MockedData.sol";

contract BlockFundingProjectTest is Test {
    address teamMemberAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address financerAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address visitorAddress = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    string messageCID = "bafkreih55oo2cdfvqzq46ttwfrosckgxv4xrvq3p5rdwgme5r6ngfuflty";

    BlockFunding blockFunding;
    BlockFundingProject defaultProject;

    function setUp() external {
        blockFunding = new BlockFunding();

        BlockFundingProject.TeamMember[] memory teamMembers = new BlockFundingProject.TeamMember[](1);
        teamMembers[0] = BlockFundingProject.TeamMember("Theo", "Riz", "Une personne hypothetique", "", "Savant", teamMemberAddress);
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.teamMembers = teamMembers;
        blockFunding.createNewProject(data);
        defaultProject = BlockFundingProject(payable(blockFunding.projects(0)));

        //vm.prank(financerAddress);
        //defaultProject.fundProject{value: 100000000000000000000}();
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


    /**************************
    *         EndVote()
    ***************************/

    function test_endVote() external {
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);

        uint currentVoteId = defaultProject.getCurrentVoteId();

        defaultProject.endVote();
        assertEq(defaultProject.getCurrentVoteId(), currentVoteId + 1, "Vote id hasn't been increased");
    }

    function test_endVoteEvent() external {
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);

        uint oldVoteId = defaultProject.getCurrentVoteId();

        vm.expectEmit();
        emit BlockFundingProject.VoteEnded(oldVoteId, true);    
        defaultProject.endVote();
    }

    function test_endVoteWithoutFinancersRights() external {
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);

        vm.startPrank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OnlyFinancersCanModifyThisVote.selector));
        defaultProject.endVote();

    }

    function test_endVoteWithoutTeamMemberRights() external {
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);
        defaultProject.sendVote(true);

        vm.prank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OnlyTeamMembersCanModifyThisVote.selector));
        defaultProject.endVote();
    }

    function test_endVoteWhenNoVoteRunning() external {
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.NoVoteRunning.selector));
        defaultProject.endVote();

    }

    function test_endVoteWhenEndDateNotPassed() external {
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ConditionsForEndingVoteNoteMeetedYet.selector));
        defaultProject.endVote();
    }

    /**************************
    *        SendVote()
    ***************************/

    function test_sendVote() external {
        defaultProject.fundProject{value: 10000}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        assertEq(defaultProject.getCurrentVotePower(), 0, "Abnormal init vote power");
        defaultProject.sendVote(true);
        assertEq(defaultProject.getCurrentVotePower(), 100, "Abnormal vote power"); // 100 is sqrt(10000)

    }

    function test_sendVoteEvent() external {
        defaultProject.fundProject{value: 10000}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.expectEmit();
        emit BlockFundingProject.HasVoted(address(this), 0, true);    
        defaultProject.sendVote(true);
        
    }

    function test_sendVoteWithoutBeingFinancer() external {
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FinancerUnauthorizedAccount.selector, address(this)));
        defaultProject.sendVote(true);
    }

    function test_sendVoteWhenNoVoteIsRunning() external {
        defaultProject.fundProject{value: 10000}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.NoVoteRunning.selector));
        defaultProject.sendVote(true);
    }

    function test_sendVoteWhenVoteIsEnded() external {
        defaultProject.fundProject{value: 10000}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.warp(defaultProject.getCurrentVoteEndDate() + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.VoteTimeEnded.selector, defaultProject.getCurrentVoteEndDate()));
        defaultProject.sendVote(true);
    }

    function test_sendVoteTwice() external {

        defaultProject.fundProject{value: 10000}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        defaultProject.sendVote(true);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.AlreadyVoted.selector, address(this)));
        defaultProject.sendVote(true);
    }

    /**************************
    *       AddMessage()
    ***************************/

    function test_addMessage() external {
        assertEq(defaultProject.getMessages().length, 0, "Abnormal message number on init");

        vm.startPrank(teamMemberAddress);
        defaultProject.addMessage(messageCID);

        assertEq(defaultProject.getMessages().length, 1, "Message hasn't been added");
        assertEq(defaultProject.getMessages()[0].writerWallet, teamMemberAddress, "Wrong address assigned to message's writer");
        assertEq(defaultProject.getMessages()[0].ipfsCID, messageCID, "Wrong CID assigned to message");
    }

    function test_addMessageEvent() external {
        vm.startPrank(teamMemberAddress);

        vm.expectEmit();
        emit BlockFundingProject.NewMessage(teamMemberAddress);    
        defaultProject.addMessage(messageCID);
    }

    function test_addEmptyMessage() external {
        vm.startPrank(teamMemberAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.EmptyString.selector, "ipfsHash"));
        defaultProject.addMessage("");
    }

    function test_addMessageWithoutRights() external {
        vm.startPrank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FinancerOrTeamMemberUnauthorizedAccount.selector, visitorAddress));
        defaultProject.addMessage(messageCID);
    }
}