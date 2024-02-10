// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./BlockFundingProject.sol";
import "./tools/Strings.sol";

/**
* @author Julien P.
* This script will handle the whole BlockFunding storage and functions.
* It will store the users and the projects. For the projects, we only store addresses, as each project has is own contract.
* BlockFunding contract will use Clone's pattern, to create contracts for each new project with reduces gas cost
* 
*/
contract BlockFunding is Ownable {
    BlockFundingProject private projectToClone;
    address[] public projects;

    enum ProjectCategory {
        art,
        automobile,
        software
    }

    event NewProjectHasBeenCreated(address projectAddress);

    constructor() Ownable(msg.sender) {
        projectToClone = new BlockFundingProject();
    }

    /**
    * @notice Here we take arrays of parameters, as solidity can only handle 16 variables manipulations.
    * Arrays are a way to deal with it, without costing too much in gas to transform datas back, that's why
    * I use multiples array, to keep the types of variables, instead of one big bytes array.
    */
    function createNewContract(
        string[3] memory _name_subtitle_description,
        string[] memory _mediasURI,
        uint[4] calldata _campaignStartAndEndingDate_estimatedProjectReleaseDate_fundingRequested,
        address _targetWallet,
        ProjectCategory _projectCategory
    ) public returns(address){
        //TODO Maybe use a mapping to pass parameters, like mapping(string => bytes[]) with
        address newProjectAddress = Clones.clone(address(projectToClone));

        BlockFundingProject project = BlockFundingProject(payable(newProjectAddress));
        project.setName(_name_subtitle_description[0]);
        project.setSubtitle(_name_subtitle_description[1]);
        project.setDescription(_name_subtitle_description[2]);
        project.setMediasURI(_mediasURI);
        project.setCampaingnStartingDateTimestamp(uint32(_campaignStartAndEndingDate_estimatedProjectReleaseDate_fundingRequested[0]));
        project.setCampaignEndingDateTimestamp(uint32(_campaignStartAndEndingDate_estimatedProjectReleaseDate_fundingRequested[1]));
        project.setEstimatedProjectReleaseDateTimestamp(uint32(_campaignStartAndEndingDate_estimatedProjectReleaseDate_fundingRequested[2]));
        project.setFundingRequested(uint96(_campaignStartAndEndingDate_estimatedProjectReleaseDate_fundingRequested[3]));
        project.setTargetWallet(_targetWallet);
        project.setProjectCategory(_projectCategory);
        project.initialize(msg.sender);

        projects.push(newProjectAddress);

        emit NewProjectHasBeenCreated(newProjectAddress);
        return newProjectAddress;
    }

    /**
    * @notice Get all projects addresses
    * @return address[] List of projects addresses
    */
    function getProjectsAddresses() public view returns(address[] memory) {
        return projects;
    }

    /**
    * @notice Get all projets data. Used to optimize frontend.
    * @return BlockFundingProject[] List of projects
    */
    function getProjects() public view returns(BlockFundingProject.ProjectData[] memory) {
        BlockFundingProject.ProjectData[] memory ret = new BlockFundingProject.ProjectData[](projects.length);
        for(uint i; i < projects.length; i++) {
            ret[i] = BlockFundingProject(payable(projects[i])).getData();
        }

        return ret;
    }
}
