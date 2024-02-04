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
    /**
    * @notice The current amount requested
    * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
    */
    uint96 public currentFunding;

    /// @notice The wallet into which the funds will be paid
    address targetWallet;
    /**
    * @notice The amount of fundig (in WEI) to reach
    * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
    */
    uint96 fundingRequested;

    /** 
    * @notice Starting date of the crowdfunding campaign, in timestamp (seconds) format
    * @dev uint32 allows timestamp up to year 2170, should be enough 
    */
    uint32 campaignStartingDateTimestamp;
    /** 
    * @notice Ending date of the crowdfunding campaign, in timestamp (seconds)  format
    * @dev uint32 allows timestamp up to year 2170, should be enough 
    */
    uint32 campaignEndingDateTimestamp;
    /** 
    * @notice Estimated date of projet release, in timestamp (seconds)  format 
    * @dev uint32 allows timestamp up to year 2170, should be enough 
    */
    uint32 estimatedProjectReleaseDateTimestamp;

    /// @notice Category of the project (like art, automobile, sport, etc ...)
    BlockFunding.ProjectCategory projectCategory; 

    /// @notice Project's name
    string name;
    /// @notice A short description of the project, used for some displays in frontend
    string subtitle;
    /// @notice Description of the project
    string description;
    /// @notice List of medias linked to the project //TODO => Maybe use a map here ? 
    string[] mediasURI;

    /// @notice Map of financers and their donations
    mapping(address => uint) public financersDonations;




   

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
    */
    function initialize () public initializer { 
        owner = msg.sender;
    }

    receive() external payable {}
    fallback() external payable {}

    function getName() external view returns (string memory){
        return name;
    }
    
    function setName(string calldata _name) external onlyOwner {
        name = _name;
    }

    function setSubtitle(string calldata _subtitle) external onlyOwner {
        subtitle = _subtitle;
    }

    function setDescription(string calldata _description) external onlyOwner {
        description = _description;
    }

    function setMediasURI(string[] memory _mediasURI) external onlyOwner {
        mediasURI = _mediasURI;
    }

    function setTargetWallet(address _targetWallet) external onlyOwner {
        targetWallet = _targetWallet;
    }

    function setCampaingnStartingDateTimestamp(uint32 _campaignStartingDateTimestamp) external onlyOwner {
        campaignStartingDateTimestamp = _campaignStartingDateTimestamp;
    }

    function setCampaignEndingDateTimestamp(uint32 _campaignEndingDateTimestamp) external onlyOwner {
        campaignEndingDateTimestamp = _campaignEndingDateTimestamp;
    }

    function setEstimatedProjectReleaseDateTimestamp(uint32 _estimatedProjectReleaseDateTimestamp) external onlyOwner {
        estimatedProjectReleaseDateTimestamp = _estimatedProjectReleaseDateTimestamp;
    }

    function setProjectCategory(BlockFunding.ProjectCategory _projectCategory) external onlyOwner {
        projectCategory = _projectCategory;
    }

    function setFundingRequested(uint96 _fundingRequested) external onlyOwner {
        fundingRequested = _fundingRequested;
    }
}
