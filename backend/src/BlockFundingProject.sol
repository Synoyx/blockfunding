// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import "./BlockFunding.sol";

/**
* @dev We use Initializable from Openzeppelin to ensure the method Initializable will only be called once.
* We don't use constructor because this contract will be cloned to reduce gas costs
*/
contract BlockFundingProject is Initializable, Ownable {
    string public name;
    string public subtitle;
    string public description;
    string[] public mediasURI;
    address public targetWallet;
    uint public campaignStartingDateTimestamp;
    uint public campaignEndingDateTimestamp;
    uint public estimatedProjectRealizationDateTimestamp;
    BlockFunding.ProjectCategory public projectCategory; 
    uint public fundingRequested;
    uint public currentFunding;

    //TODO how to implement rewards & team portraits ? 

    function initialize(
        string name,
    string subtitle,
    string description,
    string[] mediasURI,
    address targetWallet,
    uint campaignStartingDateTimestamp,
    uint campaignEndingDateTimestamp,
    uint estimatedProjectRealizationDateTimestamp,
    BlockFunding.ProjectCategory projectCategory,
    uint fundingRequested,
    uint currentFunding,
        address _owner) public {
        Ownable.initialize(_owner);

    }

}
