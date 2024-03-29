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
*/
contract BlockFunding is Ownable {
    BlockFundingProject private projectToClone;
    address[] public projects;

    enum ProjectCategory {
        art,
        automobile,
        comics,
        dance,
        design,
        fashion,
        film,
        food,
        games,
        journalism,
        music,
        publishing,
        technology,
        thater
    }

    event NewProjectHasBeenCreated();

    error AProjectIsAlreadyLiveFromThisOwner();

    modifier validProjectData(BlockFundingProject.ProjectData memory _data) {
        require(bytes(_data.name).length > 0, "Project's name mustn't be empty");
        require(bytes(_data.subtitle).length > 0, "Project's subtitle mustn't be empty");
        require(bytes(_data.description).length > 0, "Project's description mustn't be empty");
        require(bytes(_data.mediaURI).length > 0, "Project's media URI mustn't be empty");
        require(_data.owner != address(0), "You must fill owner address");
        require(_data.targetWallet != address(0), "You must fill target wallet address");
        //Removing this, as I can't make a demo with that require
        //require(_data.campaignStartingDateTimestamp > block.timestamp, "Campaign start date must be in the future");
        require(_data.campaignEndingDateTimestamp > _data.campaignStartingDateTimestamp, "Campaign end date must be after start date");
        require(_data.estimatedProjectReleaseDateTimestamp > _data.campaignEndingDateTimestamp, "Project realization date must be after campaign ending date");
        require(_data.teamMembers.length > 0, "You must give at least 1 team member");
        require(_data.projectSteps.length > 1, "You must give at least 2 project steps");

        _;
    }

    constructor() Ownable(msg.sender) {
        projectToClone = new BlockFundingProject();
    }

    /**
    * @notice Here we take arrays of parameters, as solidity can only handle 16 variables manipulations.
    * Arrays are a way to deal with it, without costing too much in gas to transform datas back, that's why
    * I use multiples array, to keep the types of variables, instead of one big bytes array.
    */
    function createNewProject(BlockFundingProject.ProjectData memory _data) public validProjectData(_data) returns(address){
        // We check if the use already have a running contract (this is to avoid DoS gas limit attack)
        for (uint i; i < projects.length; i++) {
            BlockFundingProject proj = BlockFundingProject(payable(projects[i]));
            if(proj.getOwner() == msg.sender && !proj.isProjectCanceled() && (((proj.getCurrentProjectStepId()) < proj.getData().projectSteps.length) 
                || (proj.getCurrentProjectStepId() == proj.getData().projectSteps.length 
                    && !proj.getData().projectSteps[proj.getCurrentProjectStepIndex()].hasBeenValidated))) {
                revert AProjectIsAlreadyLiveFromThisOwner();
            }
        }

        address newProjectAddress = Clones.clone(address(projectToClone));

        BlockFundingProject project = BlockFundingProject(payable(newProjectAddress));
        _data.owner = msg.sender;
        project.initialize(_data);
        emit NewProjectHasBeenCreated();

        projects.push(newProjectAddress);
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
