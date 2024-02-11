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
    struct TeamMember {
        /// @notice Team member's first name
        string firstName;

        /// @notice Team member's last name
        string lastName;

        /// @notice A short description to display on project's page
        string description;

        /// @notice a direct link to a photo to display on project's page
        string photoLink;

        /// @notice Role of the team member on the project
        string role;

        /// @notice Wallet address of team member
        address walletAddress; //TODO Make this address meaningfull by asking to stak X ETH for the project duration, to make his identity authentic
    }

    struct Message {
        /// @notice Address of write of this message
        address writerWallet;

        /**
        * @notice IPFS CID of the message.
        * We store messages offchain, to reduce TX costs.
        * We use IPFS to stay decentralized as much as possible.
        */
        string ipfsCID;

        /** 
        * @notice Date of message storage, in timestamp (seconds) format
        * @dev uint32 allows timestamp up to year 2170, should be enough 
        */
        uint32 timestamp;
    }

    struct ProjectStep {
        /// @notice Name of this project step
        string name;

        /// @notice Description of this project step
        string description;

        
        /**
        * @notice Amount needed to realize this project step (can be incremented with a vote)
        * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
        */
        uint96 amountNeeded;

        /**
        * @notice Amount currently withdrawn to realize this project step
        * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
        */
        uint96 amountFounded;

        /// @notice Does the team has withdrawn the 'amountNeeded' corresponding to this step
        bool isFounded;
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

        /// @notice List of medias linked to the project //TODO Maybe use only 1 media (for banner) ?
        string[] mediasURI;

        /// @notice List of project's team members
        TeamMember[] teamMembers;
    }

    ProjectData public data;

    /// @notice Map of financers and their donations
    mapping(address => uint) public financersDonations;

    /// @notice Map of team members. Used for modifiers mostly (reduce gas gost)
    mapping(address => bool) public teamMembers;

    /// @notice List of messages sent by financers & project creator about the project
    Message[] public messages;

    /// @notice Project's steps with their order number
    mapping(uint8 => ProjectStep) public projectSteps;

    /// @notice The current project step
    uint8 currentProjectStep;


    //TODO Do I need to implement rewards ? Or let it free with the step validation system ?


    event ContributionAddedToProject(string projectName, address contributor, uint amountInWei);
    event ProjectIsFunded(string projectName, address contributor, uint fundedAmoutInWei);
    event FundsWithdrawn(string projectName, address targetAddress, uint withdrawnAmout);
    event NewMessage(string projectName, address writer);


    error OwnableUnauthorizedAccount(address account);
    error FinancerUnauthorizedAccount(address account);
    error TeamMemberUnauthorizedAccount(address account);
    error FinancerOrTeamMemberUnauthorizedAccount(address account);
    error FundingIsntEndedYet(uint currentDate, uint campaignEndDate);
    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    modifier onlyOwner() {
        if (data.owner != msg.sender) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    modifier onlyFinancer() {
        if (financersDonations[msg.sender] == 0) {
            revert FinancerUnauthorizedAccount(msg.sender);
        }
        _;
    }

    modifier onlyTeamMember() {
        if (teamMembers[msg.sender]) {
            revert TeamMemberUnauthorizedAccount(msg.sender);
        }
        _;
    }

    modifier onlyTeamMemberOrFinancer() {
        if (financersDonations[msg.sender] == 0 || teamMembers[msg.sender]) {
            revert FinancerOrTeamMemberUnauthorizedAccount(msg.sender);
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
    * @notice As we'll clone this contract, we need to initialize owner here to BlockFundingContract's address
    */
    function initialize(ProjectData calldata _data) external reinitializer(1) { 
        data.name = _data.name;
        data.subtitle = _data.subtitle;
        data.description = _data.description;
        data.projectCategory = _data.projectCategory;
        data.campaignStartingDateTimestamp = _data.campaignStartingDateTimestamp;
        data.campaignEndingDateTimestamp = _data.campaignEndingDateTimestamp;
        data.estimatedProjectReleaseDateTimestamp = _data.estimatedProjectReleaseDateTimestamp;
        data.fundingRequested = _data.fundingRequested;
        data.targetWallet = _data.targetWallet;

        for (uint i; i < _data.mediasURI.length; i++) {
            data.mediasURI.push(_data.mediasURI[i]);
        }

        _transferOwnership(_data.owner);
    }

    function transferOwner(address _newOwner)  public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address _newOwner) internal virtual {
        if (_newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        data.owner = _newOwner;
    }

    function getOwner() external view returns(address) {
        return data.owner;
    }

    receive() external payable {}
    fallback() external payable {}


    //TODO make a withdrawForStep and a withdrawProject()
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

    function addMessage(string calldata ipfsHash) external onlyTeamMemberOrFinancer {
        messages.push(Message(msg.sender, ipfsHash, uint32(block.timestamp)));

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
