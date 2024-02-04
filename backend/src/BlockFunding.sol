// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./BlockFundingProject.sol";

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
        software
    }

    event NewProjectHasBeenCreated(address projectAddress);

    constructor() Ownable(msg.sender) {
        projectToClone = new BlockFundingProject();
    }

    function createNewContract(
        address _owner,
        string calldata _name,
        string calldata _subtitle,
        string calldata _description,
        string[] calldata _mediasURI,
        address _targetWallet,
        uint _campaignStartingDateTimestamp,
        uint _campaignEndingDateTimestamp,
        uint _estimatedProjectReleaseDateTimestamp,
        ProjectCategory _projectCategory,
        uint _fundingRequested
    ) public onlyOwner() {
        address newProjectAddress = Clones.clone(address(projectToClone));
        projects.push(newProjectAddress);

        BlockFundingProject(payable(newProjectAddress)).initialize(
            _owner,
            BlockFundingProject.ContractDetails(_name,
                _subtitle,
                _description,
                _mediasURI,
                _targetWallet,
                _campaignStartingDateTimestamp,
                _campaignEndingDateTimestamp,
                _estimatedProjectReleaseDateTimestamp,
                _projectCategory,
                _fundingRequested));

        emit NewProjectHasBeenCreated(newProjectAddress);
    }

    function getProjects() public view returns(address[] memory){
        return projects;
    }
}
