// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

import "./BlockFunding.sol";

/**
* @dev We use Initializable from Openzeppelin to ensure the method Initializable will only be called once.
* We don't use constructor because this contract will be cloned to reduce gas costs
*/
contract BlockFundingProject is Initializable {
    /**
    * @notice Owner's address. 
    * As we can't constructors, we can't use Ownable from openzeppelin, so I do it 'manually'
    */
    address public owner;
    /// @notice The current amount requested
    uint public currentFunding;
    /// @notice Map of financers and their donations
    mapping(address => uint) public financersDonations;

    /// @notice We use a struct here instead of using directly all the variables as state, to avoid stack too deep error
    ContractDetails public contractDetails;

    struct ContractDetails {
        /// @notice Project's name
        string name;
        /// @notice A short description of the project, used for some displays in frontend
        string subtitle;
        /// @notice Description of the project
        string description;
        /// @notice List of medias linked to the project //TODO => Maybe use a map here ? 
        string[] mediasURI;
         /// @notice The wallet into which the funds will be paid
        address targetWallet;
        /// @notice Starting date of the crowdfunding campaign, in timestamp (seconds) format
        uint campaignStartingDateTimestamp;
        /// @notice Ending date of the crowdfunding campaign, in timestamp (seconds)  format
        uint campaignEndingDateTimestamp;
        /// @notice Estimated date of projet release, in timestamp (seconds)  format 
        uint estimatedProjectReleaseDateTimestamp;
        /// @notice Category of the project (like art, automobile, sport, etc ...)
        BlockFunding.ProjectCategory projectCategory; 
        /// @notice The amount of fundig (in WEI) to reach
        uint fundingRequested;
    }

   

    //TODO how to implement rewards & team portraits ? 

    error OwnableUnauthorizedAccount(address account);

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    /**
    * @notice As we'll clone this contract, we initialize variables here instead of using constructor.
    *    We don't initialize financersDonations & currendFunding, as we just need the defaults values in theese variables
    *    at contract's creation.
    */
    function initialize (address _owner, ContractDetails calldata _contractDetails)
    public initializer { 
        owner = _owner;
        contractDetails.name = _contractDetails.name;
        contractDetails.subtitle = _contractDetails.subtitle;
        contractDetails.description = _contractDetails.description;
        contractDetails.targetWallet = _contractDetails.targetWallet;
        contractDetails.campaignStartingDateTimestamp = _contractDetails.campaignStartingDateTimestamp;
        contractDetails.campaignEndingDateTimestamp = _contractDetails.campaignEndingDateTimestamp;
        contractDetails.estimatedProjectReleaseDateTimestamp = _contractDetails.estimatedProjectReleaseDateTimestamp;
        contractDetails.fundingRequested = _contractDetails.fundingRequested;
    }

    receive() external payable {}
    fallback() external payable {}

    function getName() external view returns (string memory){
        return contractDetails.name;
    }
}
