// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import "forge-std/Test.sol";

import "../src/tools/Strings.sol";
import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "../script/tools/MockedData.sol";

contract BlockFundingProjectTest is Test {
    address teamMemberAddress = 0xF39Fd6E51aAd88f6f4cE6Ab8827279CFfFb92265;
    address financerAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address visitorAddress = 0x3C44CdDDb6A900fA2B585dD299E03D12fa4233Bc;

    string messageCID = "bafkreih55oo2cdfvqzq46ttwfrosckgxv4xrvq3p5rdwgme5r6ngfuflty";

    BlockFunding blockFunding;
    BlockFundingProject defaultProject;
    UnpayableTestContract unpayableTestContract;

    function setUp() external {
        blockFunding = new BlockFunding();
        unpayableTestContract = new UnpayableTestContract();

        BlockFundingProject.TeamMember[] memory teamMembers = new BlockFundingProject.TeamMember[](3);
        teamMembers[0] = BlockFundingProject.TeamMember("Theo", "Riz", "Une personne hypothetique", "http://google.fr/someimage", "Savant", teamMemberAddress);
        teamMembers[1] = MockedData.getMockedProjectDatas()[0].teamMembers[1];
        teamMembers[2] = MockedData.getMockedProjectDatas()[0].teamMembers[2];
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.teamMembers = teamMembers;
        blockFunding.createNewProject(data);
        defaultProject = BlockFundingProject(payable(blockFunding.projects(0)));
    }


    /**************************
    *     TransferOwner()
    ***************************/

    function test_transferOwner() external {
        vm.prank(defaultProject.getOwner());
        defaultProject.transferOwner(visitorAddress);

        assertEq(defaultProject.getOwner(), visitorAddress, "Owner transfer doesn't work !");
    }

    function test_transferOwnerWithoutBeingOwner() external {
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OwnableUnauthorizedAccount.selector, visitorAddress));
        vm.prank(visitorAddress);
        defaultProject.transferOwner(visitorAddress);
    }


    function test_transferOwnerWithEmptyAddress() external {
        vm.prank(defaultProject.getOwner());
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OwnableInvalidOwner.selector, address(0)));
        defaultProject.transferOwner(address(0));
    }

    /**************************
    *   WithdrawCurrentStep()
    ***************************/

    function test_withdrawCurrentStep() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);


        assertEq(address(defaultProject).balance, defaultProject.getFundingRequested(), "Balance of project seems abnormal");

        uint amountToWithdraw = defaultProject.getData().projectSteps[0].amountNeeded - defaultProject.getData().projectSteps[0].amountFunded;

        vm.prank(teamMemberAddress);
        defaultProject.withdrawCurrentStep();

        assertEq(address(defaultProject).balance, defaultProject.getFundingRequested() - amountToWithdraw, "Balance of project seems abnormal");
    }

    function test_withdrawCurrentStepEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);



        uint amountToWithdraw = defaultProject.getData().projectSteps[0].amountNeeded - defaultProject.getData().projectSteps[0].amountFunded;

        vm.expectEmit();
        emit BlockFundingProject.FundsWithdrawn(defaultProject.getData().targetWallet, amountToWithdraw);   
        vm.prank(teamMemberAddress);
        defaultProject.withdrawCurrentStep();

    }

    function test_withdrawCurrentStepWithoutBeingTeamMember() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.TeamMemberUnauthorizedAccount.selector, address(this)));
        defaultProject.withdrawCurrentStep();
    }

    function test_withdrawCurrentStepInFundingPhase() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectIsntFunded.selector));
        vm.prank(teamMemberAddress);
        defaultProject.withdrawCurrentStep();
    }

    function test_withdrawCurrentStepWithProjectCanceled() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        vm.prank(teamMemberAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectHasBeenCanceled.selector));
        defaultProject.withdrawCurrentStep();
    }

    function test_withdrawCurrentStepTwice() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);



        vm.startPrank(teamMemberAddress);
        defaultProject.withdrawCurrentStep();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.CurrentStepFundsAlreadyWithdrawn.selector));
        defaultProject.withdrawCurrentStep();

    }

    /**************************
    *   EndProjectWithdraw()
    ***************************/

    function test_endProjectWithdraw() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.warp(defaultProject.getData().estimatedProjectReleaseDateTimestamp + 1);

        assertEq(address(defaultProject).balance, defaultProject.getFundingRequested(), "Balance of project seems abnormal");
        vm.prank(teamMemberAddress);
        defaultProject.endProjectWithdraw();
        assertEq(address(defaultProject).balance, 0, "Balance of project seems abnormal");
    }

    function test_endProjectWithdrawEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.warp(defaultProject.getData().estimatedProjectReleaseDateTimestamp + 1);

        vm.expectEmit();
        emit BlockFundingProject.FundsWithdrawn(defaultProject.getData().targetWallet, defaultProject.getFundingRequested());   
        vm.prank(teamMemberAddress);
        defaultProject.endProjectWithdraw();
    }

    function test_endProjectWithdrawWithoutTeamMemberRights() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.warp(defaultProject.getData().estimatedProjectReleaseDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.TeamMemberUnauthorizedAccount.selector, address(this)));
        defaultProject.endProjectWithdraw();
    }

    function test_endProjectWithdrawWithEmptyBalance() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);


        vm.prank(teamMemberAddress);
        defaultProject.withdrawCurrentStep();

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.warp(defaultProject.getData().estimatedProjectReleaseDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        defaultProject.endProjectWithdraw();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectBalanceIsEmpty.selector));
        vm.prank(teamMemberAddress);
        defaultProject.endProjectWithdraw();
    }

    function test_endProjectWithdrawBeforeEndProject() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectIsntEndedYet.selector));
        vm.prank(teamMemberAddress);
        defaultProject.endProjectWithdraw();
    }

    function test_endProjectWithdrawBeforeValidationOfLastStep() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length - 1; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }
        
        vm.warp(defaultProject.getData().estimatedProjectReleaseDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.LastStepOfProjectNotValidatedYet.selector));
        vm.prank(teamMemberAddress);
        defaultProject.endProjectWithdraw();
    }

    /**************************
    * ProjectNotFundedWithdraw()
    ***************************/

    function test_projectNotFundedWithdraw() external {
        defaultProject.fundProject{value: 2000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        assertEq(address(defaultProject).balance, 2000, "Balance of project seems abnormal");
        defaultProject.projectNotFundedWithdraw();
        assertEq(address(defaultProject).balance, 0, "Balance of project seems abnormal");
    }

    function test_projectNotFundedWithdrawEvent() external {
        defaultProject.fundProject{value: 2000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectEmit();
        emit BlockFundingProject.FundsWithdrawn(address(this), 2000);   
        defaultProject.projectNotFundedWithdraw();
    }

    function test_withdrawCurrentStepFromUnpayableContract() external {
        // We need to do that to give funds to Unpayable contract
        SuicideContractToFeedUnpayableContract suicideContract = new SuicideContractToFeedUnpayableContract();
        (bool success, ) = payable(address(suicideContract)).call{value: 20000}("");
        assertEq(success, true, "Funding contract for testing failed");
        suicideContract.destructTo(address(unpayableTestContract));
        
        vm.prank(address(unpayableTestContract));
        defaultProject.fundProject{value: 10000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FailWithdrawTo.selector, address(unpayableTestContract)));
        vm.prank(address(unpayableTestContract));
        defaultProject.projectNotFundedWithdraw();
    }

    function test_projectNotFundedWithdrawWithoutFinancerRights() external {
        defaultProject.fundProject{value: 2000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.startPrank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FinancerUnauthorizedAccount.selector, visitorAddress));
        defaultProject.projectNotFundedWithdraw();
    }

    function test_projectNotFundedWithdrawWhileBeingInFundingPhase() external {
        defaultProject.fundProject{value: 2000}();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FundingIsntEndedYet.selector, block.timestamp, defaultProject.getData().campaignEndingDateTimestamp));
        defaultProject.projectNotFundedWithdraw();
    }

    function test_projectNotFundedWithdrawWithProjectFunded() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectIsFundedYouCantWithdrawNow.selector));
        defaultProject.projectNotFundedWithdraw();
    }

    /**************************
    * WithdrawProjectCanceled()
    ***************************/

    function test_withdrawProjectCanceled() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        assertEq(address(defaultProject).balance, defaultProject.getFundingRequested(), "Balance of project seems abnormal");
        defaultProject.withdrawProjectCanceled();
        assertEq(address(defaultProject).balance, 0, "Balance of project seems abnormal");
    }

    function test_withdrawProjectCanceledEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        vm.expectEmit();
        emit BlockFundingProject.FundsWithdrawn(address(this), defaultProject.getFundingRequested());   
        defaultProject.withdrawProjectCanceled();
    }

    function test_withdrawProjectCanceledWithoutBeingFinancer() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        vm.startPrank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FinancerUnauthorizedAccount.selector, visitorAddress));
        defaultProject.withdrawProjectCanceled();
    }

    function test_withdrawProjectCanceledWhileBeingInFundingPhase() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FundingIsntEndedYet.selector, block.timestamp, defaultProject.getData().campaignEndingDateTimestamp));
        defaultProject.withdrawProjectCanceled();

    }

    function test_withdrawProjectCanceledWithoutProjectBeingCanceled() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectHasntBeenCanceled.selector));
        defaultProject.withdrawProjectCanceled();
    }


    /**************************
    *      FundProject()
    ***************************/

    function test_fundProject() external {
        assertEq(defaultProject.getData().totalFundsHarvested, 0, "Total funds at init aren't set at 0");
        defaultProject.fundProject{value: 10000}();
        assertEq(defaultProject.getData().totalFundsHarvested, 10000, "Total funds isn't refresh after add funds");
    }

    function test_fundProjectEvent() external {
        vm.expectEmit();
        emit BlockFundingProject.ContributionAddedToProject(address(this), 10000);  
        defaultProject.fundProject{value: 10000}();

        vm.expectEmit();
        emit BlockFundingProject.ProjectIsFunded(address(this), defaultProject.getFundingRequested() + 10000);   
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
    }

    function test_fundProjectTwice() external {
        assertEq(defaultProject.getTotalVotePower(), 0, "Total vote power isn't set at 0");
        defaultProject.fundProject{value: 10000}();
        assertEq(defaultProject.getTotalVotePower(), 100, "Total vote power isn't computed correctly");
        defaultProject.fundProject{value: 10000}();
        assertEq(defaultProject.getTotalVotePower(), 141, "Total vote power isn't computed correctly");
    }

    function test_fundProjectAfterFundingPhasePassed() external {
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FundingIsEnded.selector, block.timestamp, defaultProject.getData().campaignEndingDateTimestamp));
        defaultProject.fundProject{value: 10000}();
    }

    function test_fundProjectWithTooLowAmount() external {
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FundingAmountIsTooLow.selector));
        defaultProject.fundProject{value: 1}();
    }

    /**************************
    *    AskForMoreFunds()
    ***************************/

    function test_askForMoreFunds() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        assertEq(defaultProject.isCurrentVoteRunning(), false, "Abnormal running vote state in init");
        vm.prank(teamMemberAddress);
        defaultProject.askForMoreFunds(1000);
        assertEq(defaultProject.isCurrentVoteRunning(), true, "Abnormal running vote state after starting vote");
    }

    function test_askForMoreFundsEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.startPrank(teamMemberAddress);
        vm.expectEmit();
        emit BlockFundingProject.VoteStarted(defaultProject.getCurrentVoteId(), BlockFundingProject.VoteType.AddFundsForStep);    
        defaultProject.askForMoreFunds(1000);
    }

    function test_askForMoreFundsWithoutTeamMemberRights() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.TeamMemberUnauthorizedAccount.selector, address(this)));
        defaultProject.askForMoreFunds(1000);
    }

    function test_askForMoreFundsInFundingPhase() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectIsntFunded.selector));
        vm.prank(teamMemberAddress);
        defaultProject.askForMoreFunds(1000);
    }

    function test_askForMoreFundsWhenProjectIsCanceled() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectHasBeenCanceled.selector));
        vm.prank(teamMemberAddress);
        defaultProject.askForMoreFunds(1000);
    }

    function test_askForMoreFundsWhenVoteIsRunning() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.VoteIsAlreadyRunning.selector));
        vm.prank(teamMemberAddress);
        defaultProject.askForMoreFunds(1000);
    }

    function test_askForMoreFundsWithTooMuchAmount() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        uint valueFunded = defaultProject.getFundingRequested();

        vm.startPrank(teamMemberAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.AmountAskedTooHigh.selector));
        defaultProject.askForMoreFunds(valueFunded + 1);
    }

    /**************************
    *       StartVote()
    ***************************/

    function test_startVote() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        assertEq(defaultProject.isCurrentVoteRunning(), false, "Abnormal running vote state in init");
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        assertEq(defaultProject.isCurrentVoteRunning(), true, "Abnormal running vote state after starting vote");
    }

    function test_startVoteEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectEmit();
        emit BlockFundingProject.VoteStarted(defaultProject.getCurrentVoteId(), BlockFundingProject.VoteType.WithdrawProjectToFinancers);    
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
    }

    function test_startVoteToCancelOnLastStep() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.CantCancelProjectAtTheLastStep.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
    }

    function test_startVoteWithoutFinancersRights() external {
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OnlyFinancersCanModifyThisVote.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
    }

    function test_startVoteWithoutTeamMemberRights() external {
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OnlyTeamMembersCanModifyThisVote.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);
    }

    function test_startVoteInFundingPhase() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectIsntFunded.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
    }

    function test_startVoteWhenProjectIsCanceled() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ProjectHasBeenCanceled.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
    }

    function test_startVoteWhenVoteIsRunning() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.VoteIsAlreadyRunning.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
    }

    function test_startVoteWithWrongVoteType() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        
        vm.prank(teamMemberAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.UseDedicatedMethodToStartAskFundsVote.selector));
        defaultProject.startVote(BlockFundingProject.VoteType.AddFundsForStep);
    }


    /**************************
    *         EndVote()
    ***************************/

    function test_endVote() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);

        uint currentVoteId = defaultProject.getCurrentVoteId();

        defaultProject.endVote();
        assertEq(defaultProject.getCurrentVoteId(), currentVoteId + 1, "Vote id hasn't been increased");
    }

    function test_endVoteEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);

        uint oldVoteId = defaultProject.getCurrentVoteId();

        vm.expectEmit();
        emit BlockFundingProject.VoteEnded(oldVoteId, true);    
        defaultProject.endVote();
    }

    function test_endVoteWithoutVote() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 3*24*60*60 + 1);

        uint currentVoteId = defaultProject.getCurrentVoteId();
        defaultProject.endVote();
        assertEq(defaultProject.getCurrentVoteId(), currentVoteId + 1, "Vote id hasn't been increased");
        assertEq(defaultProject.isLastVoteValidated(), false, "Vote has been validated, it shouldn't in that case");
    }

    function test_endVoteOnAddFundsForStep() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested() + 1000000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);


        vm.prank(teamMemberAddress);
        defaultProject.withdrawCurrentStep();

        vm.prank(teamMemberAddress);
        defaultProject.askForMoreFunds(1000);

        defaultProject.sendVote(true);

        uint oldAmountNeeded = defaultProject.getData().projectSteps[defaultProject.getCurrentProjectStepIndex()].amountNeeded;

        assertEq(defaultProject.getData().projectSteps[defaultProject.getCurrentProjectStepIndex()].isFunded, true, "Project step is already funded on init");
        vm.prank(teamMemberAddress);
        defaultProject.endVote();

        assertEq(defaultProject.getData().projectSteps[defaultProject.getCurrentProjectStepIndex()].isFunded, false, "Project step isfunded hasn't changed");
        assertEq(defaultProject.getData().projectSteps[defaultProject.getCurrentProjectStepIndex()].amountNeeded, oldAmountNeeded + 1000, "Project step amount needed hasn't changed");
        assertEq(defaultProject.isLastVoteValidated(), true, "Vote hasn't been validated");
    }

    function test_endVoteWithoutFinancersRights() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);

        vm.startPrank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OnlyFinancersCanModifyThisVote.selector));
        defaultProject.endVote();

    }

    function test_endVoteWithoutTeamMemberRights() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);
        defaultProject.sendVote(true);

        vm.prank(visitorAddress);
        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.OnlyTeamMembersCanModifyThisVote.selector));
        defaultProject.endVote();
    }

    function test_endVoteWhenNoVoteRunning() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.NoVoteRunning.selector));
        defaultProject.endVote();

    }

    function test_endVoteWhenEndDateNotPassed() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);
        
        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.ConditionsForEndingVoteNoteMeetedYet.selector));
        defaultProject.endVote();
    }

    /**************************
    *        SendVote()
    ***************************/

    function test_sendVote() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        assertEq(defaultProject.getCurrentVotePower(), 0, "Abnormal init vote power");
        defaultProject.sendVote(true);
        assertEq(defaultProject.getCurrentVotePower(), Maths.sqrt(defaultProject.getFundingRequested()), "Abnormal vote power");

    }

    function test_sendVoteEvent() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.expectEmit();
        emit BlockFundingProject.HasVoted(address(this), 0, true);    
        defaultProject.sendVote(true);
        
    }

    function test_sendVoteTotalPowerAdded() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        assertEq(defaultProject.getCurrentVotePowerAgainstProposal(), 0, "Abnormal init vote power");
        defaultProject.sendVote(false);
        assertEq(defaultProject.getCurrentVotePowerAgainstProposal(), Maths.sqrt(defaultProject.getFundingRequested()), "Abnormal vote power");
    }

    function test_sendVoteWithoutBeingFinancer() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.FinancerUnauthorizedAccount.selector, visitorAddress));
        vm.prank(visitorAddress);
        defaultProject.sendVote(true);
    }

    function test_sendVoteWhenNoVoteIsRunning() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.NoVoteRunning.selector));
        defaultProject.sendVote(true);
    }

    function test_sendVoteWhenVoteIsEnded() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);

        vm.warp(defaultProject.getCurrentVoteEndDate() + 1);

        vm.expectRevert(abi.encodeWithSelector(BlockFundingProject.VoteTimeEnded.selector, defaultProject.getCurrentVoteEndDate()));
        defaultProject.sendVote(true);
    }

    function test_sendVoteTwice() external {

        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();

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


    /**************************
    *     getCurrentVote()
    ***************************/

    function test_getCurrentVote() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        defaultProject.askForMoreFunds(1000);

        defaultProject.sendVote(true);

        BlockFundingProject.SimplifiedVote memory vote = defaultProject.getCurrentVote(address(this));
        assertEq(vote.stepNumber, 1, "Wrong step number returned in currentVote getter");
        assertEq(vote.askedAmountToAddForStep, 1000, "Wrong asked amount returned in currentVote getter");
        assertEq(vote.hasVoteBeenValidated, false, "Wrong flag returned in currentVote getter");
        assertEq(vote.isVoteRunning, true, "Wrong is vote running flag returned in currentVote getter");
        assertEq(vote.hasFinancerVoted, true, "Wrong has voted flag returned in currentVote getter");
    }

    /******************************
    *  getFinancerDonationAmount()
    ******************************/

    function test_getFinancerDonationAmount() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        assertEq(defaultProject.getFinancerDonationAmount(address(this)), defaultProject.getFundingRequested(), "Wrong donation amount for given financer returned");
    }

    /*****************************************
    *  isProjectCanceledOrLastStepValidated()
    *****************************************/

    function test_isProjectCanceledOrLastStepValidated() external {
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        assertEq(defaultProject.isProjectCanceledOrLastStepValidated(), false, "Wrong return for project status");

        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        assertEq(defaultProject.isProjectCanceledOrLastStepValidated(), true, "Wrong return for project status");
    }

    /*****************************************
    *               isFinancer()
    *****************************************/

    function test_isFinancer() external {
        assertEq(defaultProject.isFinancer(address(this)), false, "Wrong return for financer status");
        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        assertEq(defaultProject.isFinancer(address(this)), true, "Wrong return for financer status");
    }


    /*****************************************
    *    isWithdrawCurrentStepAvailable()
    *****************************************/

    function test_isWithdrawCurrentStepAvailable() external {
        assertEq(defaultProject.isWithdrawCurrentStepAvailable(), false, "Wrong return for withdrawflag");

        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        assertEq(defaultProject.isWithdrawCurrentStepAvailable(), true, "Wrong return for withdrawflag");
    }


    /*****************************************
    *    isWithdrawEndProjectAvailable()
    *****************************************/

    function test_isWithdrawEndProjectAvailable() external {
        assertEq(defaultProject.isWithdrawEndProjectAvailable(address(this)), false, "Wrong return for withdrawflag");

        defaultProject.fundProject{value: defaultProject.getFundingRequested() + 1}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        for (uint i; i < defaultProject.getData().projectSteps.length; i++) {
            vm.prank(teamMemberAddress);
            defaultProject.startVote(BlockFundingProject.VoteType.ValidateStep);

            defaultProject.sendVote(true);

            vm.prank(teamMemberAddress);
            defaultProject.endVote();
        }

        vm.warp(defaultProject.getData().estimatedProjectReleaseDateTimestamp + 1);

        vm.prank(teamMemberAddress);
        assertEq(defaultProject.isWithdrawEndProjectAvailable(teamMemberAddress), true, "Wrong return for withdrawflag");
    }


    /*****************************************
    *  isWithdrawProjectNotFundedAvailable()
    *****************************************/

    function test_isWithdrawProjectNotFundedAvailable() external {
        assertEq(defaultProject.isWithdrawProjectNotFundedAvailable(address(this)), false, "Wrong return for withdrawflag");

        defaultProject.fundProject{value: 2000}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        assertEq(defaultProject.isWithdrawProjectNotFundedAvailable(address(this)), true, "Wrong return for withdrawflag");
    }

    /*****************************************
    *  isWithdrawProjectCanceledAvailable()
    *****************************************/

    function test_isWithdrawProjectCanceledAvailable() external {
        assertEq(defaultProject.isWithdrawProjectCanceledAvailable(address(this)), false, "Wrong return for withdrawflag");

        defaultProject.fundProject{value: defaultProject.getFundingRequested()}();
        vm.warp(defaultProject.getData().campaignEndingDateTimestamp + 1);

        defaultProject.startVote(BlockFundingProject.VoteType.WithdrawProjectToFinancers);
        defaultProject.sendVote(true);
        defaultProject.endVote();

        assertEq(defaultProject.isWithdrawProjectCanceledAvailable(address(this)), true, "Wrong return for withdrawflag");
    }


    /*****************************************
    *         endFundingCampaign()
    *****************************************/

    function test_endFundingCampaign() external {
        assertEq(defaultProject.getData().campaignEndingDateTimestamp > block.timestamp, true, "Wrong ending date");

        vm.prank(teamMemberAddress);
        defaultProject.endFundingCampaign();

        assertEq(defaultProject.getData().campaignEndingDateTimestamp > block.timestamp, false, "EndFundingCampaign doesn't works");
    }
    

    receive() external payable {}
    fallback() external payable {}
}

contract UnpayableTestContract {}

contract SuicideContractToFeedUnpayableContract {
    function destructTo(address _to) external {
        selfdestruct(payable(_to));
    }

    receive() external payable {}

    /// @dev I add this line to make forge coverage ignore this class
    function test() public {}
}