// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';


import "./BlockFunding.sol";

/**
* @dev We use Initializable from Openzeppelin to ensure the method Initializable will only be called once.
* We don't use constructor because this contract will be cloned to reduce gas costs
*/
contract BlockFundingProject is Initializable, ReentrancyGuard {
    struct Message {
        address sender;
        string ipfsHash; // We store message content on IPFS to reduce storage cost on blockchain
        uint256 timestamp;
    }

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

    /// @notice Flag to know if project creator has withdrawn 
    bool hasBeenWithdrawn;

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

    /// @notice List of messages sent by financers & project creator about the project
    Message[] public messages;

    //TODO how to implement rewards & team portraits ? 


    event ContributionAddedToProject(string projectName, address contributor, uint amountInWei);
    event ProjectIsFunded(string projectName, address contributor, uint fundedAmoutInWei);
    event FundsWithdrawn(string projectName, address targetAddress, uint withdrawnAmout);
    event NewMessage(string projectName, address writer);

   


    error OwnableUnauthorizedAccount(address account);
    error FundingIsntEndedYet(uint currentDate, uint campaignEndDate);

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    modifier fundingDatePassed {
        if (campaignEndingDateTimestamp < block.timestamp) {
            revert FundingIsntEndedYet(block.timestamp, campaignEndingDateTimestamp);
        }
        _;
    }
    modifier fundingDateNotPassed {
        if (campaignEndingDateTimestamp > block.timestamp) {
            revert FundingIsntEndedYet(block.timestamp, campaignEndingDateTimestamp);
        }
        _;
    }

    /**
    * @notice As we'll clone this contract, we initialize variables here instead of using constructor.
    */
    function initialize() external initializer { 
        owner = msg.sender;
    }

    receive() external payable {}
    fallback() external payable {}

    function withdraw() external onlyOwner fundingDatePassed nonReentrant  {
        require(checkIfProjectIsFunded(), "Project hasn't been funded yet, you can't withdraw funds !");
        require(!hasBeenWithdrawn, "Funds have already been withdrawn");

        hasBeenWithdrawn = true;
        uint96 withdrawnAmount = currentFunding;
        currentFunding -= withdrawnAmount;
        payable(targetWallet).transfer(withdrawnAmount);

        emit FundsWithdrawn(name, targetWallet, currentFunding);
    }

    function fundProject() external payable fundingDateNotPassed {
        require(msg.value > 0, "Funding amount must be greater than 0");
        bool projectWasAlreadyFunded = checkIfProjectIsFunded();
        currentFunding += uint96(msg.value);

        financersDonations[msg.sender] += uint96(msg.value);

        emit ContributionAddedToProject(name, msg.sender, msg.value);
        
        if (checkIfProjectIsFunded() && !projectWasAlreadyFunded) {
            emit ProjectIsFunded(name, msg.sender, currentFunding);
        }
    }

    function addMessage(string calldata ipfsHash) external {
        require(financersDonations[msg.sender] > 0 || msg.sender == owner, 
            "You need to be the project creator or a financer to add a message");

        messages.push(Message(msg.sender, ipfsHash, block.timestamp));

        emit NewMessage(name, msg.sender);
    }

    function checkIfProjectIsFunded() public view returns (bool) {
        return currentFunding >= fundingRequested;
    }

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
