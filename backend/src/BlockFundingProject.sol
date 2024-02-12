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
        address walletAddress;
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
        uint96 amountFunded;

        /// @notice Does the team has withdrawn the 'amountNeeded' corresponding to this step
        bool isFounded;

        /// @notice The order number of this step (lower is sooner)
        uint8 orderNumber;

        /// @notice Project step has been validated with a financer's vote
        bool hasBeenValidated;
    }

    struct ProjectData {
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

        /// @notice The wallet into which the funds will be paid
        address targetWallet;

        /**
        * @notice Owner's address. 
        * As we can't constructors, we can't use Ownable from openzeppelin, so I do it 'manually'
        */
        address owner;
        /**
        * @notice The total amount harvested
        * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
        */
        uint96 totalFundsHarvested;

        /// @notice Category of the project (like art, automobile, sport, etc ...)
        BlockFunding.ProjectCategory projectCategory; 

        /// @notice Project's name
        string name;

        /// @notice A short description of the project, used for some displays in frontend
        string subtitle;

        /// @notice Description of the project
        string description;

        /// @notice Media URI used as banner in project details page
        string mediaURI;

        /// @notice List of project's team members
        TeamMember[] teamMembers;

        /** 
        * @notice Project's steps with their order number
        * We use an array here because we're in a struct
        */ 
        ProjectStep[] projectSteps;
    }

    /// @notice The current project step
    uint8 currentProjectStep;

    /// @notice Financers has vote to cancel the project
    bool projectGotVoteCanceled; //TODO set it by vote

    /**
    * @notice The total amount requested (sum of project's steps amounts)
    * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
    */
    uint96 fundingRequested;

    ProjectData public data;

    /// @notice Map of financers and their donations
    mapping(address => uint96) public financersDonations;

    /// @notice Map of team members. Used for modifiers mostly (reduce gas gost)
    mapping(address => bool) public teamMembersAddresses;

    /// @notice We use this mapping to easily retrieve step by their order number while be able to easily iterate over them
    mapping(uint8 => uint8) public projectStepsOrderedIndex;

    /// @notice List of messages sent by financers & project creator about the project
    Message[] public messages;

    //TODO maybe remove project name, as an event is linked to project address
    event ContributionAddedToProject(string projectName, address contributor, uint amountInWei);
    event ProjectIsFunded(string projectName, address contributor, uint fundedAmoutInWei);
    event FundsWithdrawn(string projectName, address targetAddress, uint withdrawnAmout);
    event NewMessage(string projectName, address writer);


    error OwnableUnauthorizedAccount(address account);
    error FinancerUnauthorizedAccount(address account);
    error TeamMemberUnauthorizedAccount(address account);
    error FinancerOrTeamMemberUnauthorizedAccount(address account);
    error FundingIsntEndedYet(uint currentDate, uint campaignEndDate);
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
        if (!teamMembersAddresses[msg.sender]) {
            revert TeamMemberUnauthorizedAccount(msg.sender);
        }
        _;
    }

    modifier onlyTeamMemberOrFinancer() {
        if (financersDonations[msg.sender] == 0 || teamMembersAddresses[msg.sender]) {
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
    * @notice As we'll clone this contract, we need to initialize variables here and not in a constructor
    */
    function initialize(ProjectData calldata _data) external initializer { 
        data.name = _data.name;
        data.subtitle = _data.subtitle;
        data.description = _data.description;
        data.projectCategory = _data.projectCategory;
        data.campaignStartingDateTimestamp = _data.campaignStartingDateTimestamp;
        data.campaignEndingDateTimestamp = _data.campaignEndingDateTimestamp;
        data.estimatedProjectReleaseDateTimestamp = _data.estimatedProjectReleaseDateTimestamp;
        data.targetWallet = _data.targetWallet;
        data.mediaURI = _data.mediaURI;

        for (uint i; i < _data.teamMembers.length; i++) {
            data.teamMembers.push(_data.teamMembers[i]);
            teamMembersAddresses[_data.teamMembers[i].walletAddress] = true;
        }

        for (uint i; i < _data.projectSteps.length; i++) {
            data.projectSteps.push(_data.projectSteps[i]);
            projectStepsOrderedIndex[_data.projectSteps[i].orderNumber] = uint8(i);
            fundingRequested += _data.projectSteps[i].amountNeeded;
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

    function withdrawProjectCanceled() external onlyFinancer fundingDatePassed nonReentrant {
        require(projectGotVoteCanceled, "Project hasn't been canceled by financer's vote, you can't withdraw");

        uint256 PRECISION_FACTOR = 10 ** 12;
        uint256 amountToWithdraw = (uint256(financersDonations[msg.sender]) * address(this).balance * PRECISION_FACTOR) / uint256(data.totalFundsHarvested) / PRECISION_FACTOR;

        //We set donations to 0, to remove this user from financers's list
        financersDonations[msg.sender] = 0;

        _safeWithdraw(amountToWithdraw, msg.sender);
    }

    function withdrawCurrentStep() external onlyTeamMember fundingDatePassed nonReentrant {
        ProjectStep storage currentStep = data.projectSteps[projectStepsOrderedIndex[currentProjectStep]];
        require(!currentStep.isFounded, "Current step funds has already been withdrawn");

        uint96 amountToWithdraw = currentStep.amountNeeded - currentStep.amountFunded;
        currentStep.isFounded = true;
        currentStep.amountFunded += amountToWithdraw;
        
        _safeWithdraw(amountToWithdraw, data.targetWallet);
    }

    function endProjectWithdraw() onlyTeamMember nonReentrant external {
        require(currentProjectStep == data.projectSteps.length && data.projectSteps[projectStepsOrderedIndex[currentProjectStep]].hasBeenValidated, "Project isn't on his last step");
        require(data.estimatedProjectReleaseDateTimestamp < block.timestamp, "Project is'nt ended yet");
        require(address(this).balance > 0, "There is nothing to withdraw");

        uint96 amountToWithdraw = uint96(address(this).balance);

        _safeWithdraw(amountToWithdraw, data.targetWallet);
    }

    /**
    * @notice With that method, financers can withdraw their donations if the project hasn't reach expected funds after the campaign's
    * end date. Each financer will be able to withdraw their funds.
    *
    * @dev Don't need to check the left donations to withdraw here, as to be a financer you need to have donations left (check modifier)
    */
    function projectNotFundedWithdraw() external onlyFinancer fundingDatePassed nonReentrant {
        require(!checkIfProjectIsFunded(), "Project has received enough funds to continue, you can't withdraw now !");

        uint96 amountToWithdraw = financersDonations[msg.sender];
        financersDonations[msg.sender] = 0;

        _safeWithdraw(amountToWithdraw, msg.sender);
    }

    function _safeWithdraw(uint _amountToWithdraw, address _to) internal {
        //TODO if fail, transfer in WETH ?
        (bool success, ) = payable(_to).call{value: _amountToWithdraw}("");
        require(success, "Withdraw failed.");
        emit FundsWithdrawn(data.name, _to, _amountToWithdraw);
    }

    function fundProject() external payable fundingDateNotPassed {
        require(msg.value > 1000, "Funding amount must be greater than 1000 wei");
        bool projectWasAlreadyFunded = checkIfProjectIsFunded();
        data.totalFundsHarvested += uint96(msg.value); //TODO Potential loss here, verify if everything can be done in uint256 ?

        financersDonations[msg.sender] += uint96(msg.value);

        emit ContributionAddedToProject(data.name, msg.sender, msg.value);
        
        if (checkIfProjectIsFunded() && !projectWasAlreadyFunded) {
            emit ProjectIsFunded(data.name, msg.sender, data.totalFundsHarvested);
        }
    }

    function addMessage(string calldata ipfsHash) external onlyTeamMemberOrFinancer {
        messages.push(Message(msg.sender, ipfsHash, uint32(block.timestamp)));

        emit NewMessage(data.name, msg.sender);
    }

    function checkIfProjectIsFunded() public view returns (bool) {
        return data.totalFundsHarvested >= fundingRequested;
    }

    function getData() external view returns (ProjectData memory) {
        return data;
    }

    function getName() external view returns (string memory){
        return data.name;
    }
}
