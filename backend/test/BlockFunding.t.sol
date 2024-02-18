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

    function test_createProjectWithEmptyName() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.name = "";

        vm.expectRevert("Project's name mustn't be empty");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithEmptySubtitle() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.subtitle = "";

        vm.expectRevert("Project's subtitle mustn't be empty");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithEmptyDescription() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.description = "";

        vm.expectRevert("Project's description mustn't be empty");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithEmptyMediaURI() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.mediaURI = "";

        vm.expectRevert("Project's media URI mustn't be empty");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithEmptyOwnerAddress() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.owner = address(0);

        vm.expectRevert("You must fill owner address");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithEmptyTargetWalletAddress() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.targetWallet = address(0);

        vm.expectRevert("You must fill target wallet address");
        blockFunding.createNewProject(data);
    }

    /*
    Removing this test, because I can't make a full demo if I can't create a contract with a passed date
    function test_createProjectWithInvalidStartDate() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.campaignStartingDateTimestamp = uint32(0);

        vm.expectRevert("Campaign start date must be in the future");
        blockFunding.createNewProject(data);
    }
    */

    function test_createProjectWithInvalidEndDate() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.campaignEndingDateTimestamp = data.campaignStartingDateTimestamp;

        vm.expectRevert("Campaign end date must be after start date");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithInvalidProjectEndDate() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.estimatedProjectReleaseDateTimestamp = data.campaignEndingDateTimestamp;

        vm.expectRevert("Project realization date must be after campaign ending date");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithNoTeamMembers() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.teamMembers = new BlockFundingProject.TeamMember[](0);

        vm.expectRevert("You must give at least 1 team member");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithNoProjectStep() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.projectSteps = new BlockFundingProject.ProjectStep[](0);

        vm.expectRevert("You must give at least 2 project steps");
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithEmptyTeamMemberAddress() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.teamMembers[0].walletAddress = address(0);

        vm.expectRevert(abi.encodePacked(BlockFundingProject.GivenTargetWalletAddressIsEmpty.selector));
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithTargetWalletSameAsTeamAddress() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.teamMembers[0].walletAddress = data.targetWallet;

        vm.expectRevert(abi.encodePacked(BlockFundingProject.TargetWalletSameAsTeamMember.selector));
        blockFunding.createNewProject(data);
    }

    function test_createProjectWithMissingTeamMemberInfo() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.teamMembers[0].firstName = "";

        vm.expectRevert(abi.encodePacked(BlockFundingProject.MissingInformationForTeamMember.selector));
        blockFunding.createNewProject(data);
    }

    function test_createProjectEvent() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        vm.expectEmit();
        emit BlockFunding.NewProjectHasBeenCreated();    
        blockFunding.createNewProject(data);
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
            vm.startPrank(vm.addr(i+1));
            blockFunding.createNewProject(MockedData.getMockedProjectDatas()[0]);
            vm.stopPrank();
        }

        assertEq(blockFunding.getProjectsAddresses().length, 100, "Projects array isn't empty when BlockFunding project is initialized");
    }

    function test_projectsList() external {
        for (uint256 i; i < 3; i++) {
            vm.startPrank(vm.addr(i+1));
            blockFunding.createNewProject(MockedData.getMockedProjectDatas()[i]);
            vm.stopPrank();
        }

        assertEq(blockFunding.getProjects()[0].name, MockedData.getMockedProjectDatas()[0].name, "Name seems to not be assigned correcctly !");
        assertEq(blockFunding.getProjects()[1].name, MockedData.getMockedProjectDatas()[1].name, "Name seems to not be assigned correcctly !");
        assertEq(blockFunding.getProjects()[2].name, MockedData.getMockedProjectDatas()[2].name, "Name seems to not be assigned correcctly !");
    }

    function test_clonesAreDeployedToDifferentAddresses() external {
        address[] memory clonesAddresses = new address[](3);

        for (uint i; i < 3; i++) {
            vm.startPrank(vm.addr(i+1));
            blockFunding.createNewProject(MockedData.getMockedProjectDatas()[i]);
            vm.stopPrank();
            clonesAddresses[i] = blockFunding.projects(i);

            assertEq(arrayContainsOnlyOnce(blockFunding.projects(i), clonesAddresses), true, "Clones have the same addresses !");
        }
    }

    function test_twoLiveProjectsOnSameUser() external {
        BlockFundingProject.ProjectData memory data = MockedData.getMockedProjectDatas()[0];
        data.owner = address(this);
        for (uint i; i < 2; i++) {
            if (i == 1) vm.expectRevert(abi.encodeWithSelector(BlockFunding.AProjectIsAlreadyLiveFromThisOwner.selector));
            blockFunding.createNewProject(data);
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