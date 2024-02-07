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

    struct ProjectData {
        /**
        * @notice Owner's address. 
        * As we can't constructors, we can't use Ownable from openzeppelin, so I do it 'manually'
        */
        address owner;
        /**
        * @notice The current amount requested
        * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
        */
        uint96 currentFunding;

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
    }

    ProjectData public data;

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
        if (data.owner != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    modifier fundingDatePassed {
        if (data.campaignEndingDateTimestamp < block.timestamp) {
            revert FundingIsntEndedYet(block.timestamp, data.campaignEndingDateTimestamp);
        }
        _;
    }
    modifier fundingDateNotPassed {
        if (data.campaignEndingDateTimestamp > block.timestamp) {
            revert FundingIsntEndedYet(block.timestamp, data.campaignEndingDateTimestamp);
        }
        _;
    }

    /**
    * @notice As we'll clone this contract, we initialize variables here instead of using constructor.
    */
    function initialize() external initializer { 
        data.owner = msg.sender;
    }

    receive() external payable {}
    fallback() external payable {}

    function withdraw() external onlyOwner fundingDatePassed nonReentrant  {
        require(checkIfProjectIsFunded(), "Project hasn't been funded yet, you can't withdraw funds !");
        require(!data.hasBeenWithdrawn, "Funds have already been withdrawn");

        data.hasBeenWithdrawn = true;
        uint96 withdrawnAmount = data.currentFunding;
        data.currentFunding -= withdrawnAmount;
        payable(data.targetWallet).transfer(withdrawnAmount);

        emit FundsWithdrawn(data.name, data.targetWallet, data.currentFunding);
    }

    function fundProject() external payable fundingDateNotPassed {
        require(msg.value > 0, "Funding amount must be greater than 0");
        bool projectWasAlreadyFunded = checkIfProjectIsFunded();
        data.currentFunding += uint96(msg.value);

        financersDonations[msg.sender] += uint96(msg.value);

        emit ContributionAddedToProject(data.name, msg.sender, msg.value);
        
        if (checkIfProjectIsFunded() && !projectWasAlreadyFunded) {
            emit ProjectIsFunded(data.name, msg.sender, data.currentFunding);
        }
    }

    function addMessage(string calldata ipfsHash) external {
        require(financersDonations[msg.sender] > 0 || msg.sender == data.owner, 
            "You need to be the project creator or a financer to add a message");

        messages.push(Message(msg.sender, ipfsHash, block.timestamp));

        emit NewMessage(data.name, msg.sender);
    }

    function checkIfProjectIsFunded() public view returns (bool) {
        return data.currentFunding >= data.fundingRequested;
    }

    function getData() external view returns (ProjectData memory) {
        return data;
    }

    function getName() external view returns (string memory){
        return data.name;
    }
    
    function setName(string calldata _name) external onlyOwner {
        data.name = _name;
    }

    function setSubtitle(string calldata _subtitle) external onlyOwner {
        data.subtitle = _subtitle;
    }

    function setDescription(string calldata _description) external onlyOwner {
        data.description = _description;
    }

    function setMediasURI(string[] memory _mediasURI) external onlyOwner {
        data.mediasURI = _mediasURI;
    }

    function setTargetWallet(address _targetWallet) external onlyOwner {
        data.targetWallet = _targetWallet;
    }

    function setCampaingnStartingDateTimestamp(uint32 _campaignStartingDateTimestamp) external onlyOwner {
        data.campaignStartingDateTimestamp = _campaignStartingDateTimestamp;
    }

    function setCampaignEndingDateTimestamp(uint32 _campaignEndingDateTimestamp) external onlyOwner {
        data.campaignEndingDateTimestamp = _campaignEndingDateTimestamp;
    }

    function setEstimatedProjectReleaseDateTimestamp(uint32 _estimatedProjectReleaseDateTimestamp) external onlyOwner {
        data.estimatedProjectReleaseDateTimestamp = _estimatedProjectReleaseDateTimestamp;
    }

    function setProjectCategory(BlockFunding.ProjectCategory _projectCategory) external onlyOwner {
        data.projectCategory = _projectCategory;
    }

    function setFundingRequested(uint96 _fundingRequested) external onlyOwner {
        data.fundingRequested = _fundingRequested;
    }
}
