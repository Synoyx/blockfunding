// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';


import "./BlockFunding.sol";
import "./tools/Maths.sol";

/**
* @dev We use Initializable from Openzeppelin to ensure the method Initializable will only be called once.
* We don't use constructor because this contract will be cloned to reduce gas costs
*/
contract BlockFundingProject is Initializable, ReentrancyGuard {
    //TODO remove uint96 things
    /* *********************** 
    *     Structs & enums
    *********************** */

    /**
    * @notice Enum used to precise which vote type the current vote will be.
    * There are 3 of them :
    * - ValidateStep : Team members ask to financers to validate the current project step by giving proof that they did what they said. 
    *    If financers are OK, project will go to the next step, and team members will be allows to withdraw next step amount 
    *    needed to the target wallet
    * - AddFundsForStep : Team members ask to allow to the current step more funds that initialy planned. The amount will be taken on the 
    *    left balance of the contract (that equals currentContractBalance - sum(nextStepsFundsNeeded))
    * - WithdrawProjectToFinancers : Financers can vote to stop project on the current step, and withdraw the leftover amount on the contract.
    *    this gives power to financers, and ensure that project's team won't be able to scam financers.
    */
    enum VoteType {
        ValidateStep, 
        AddFundsForStep,
        WithdrawProjectToFinancers
    }


    struct Vote {
        /// @notice Type of vote (see enum comment for more details)
        VoteType voteType;

        /// @notice End vote date, in timestamp second format
        uint96 endVoteDate;

        /// @notice Mapping to keep a trace of who has voted
        mapping (address => bool) hasFinancerVoted;

        /// @notice Variable only use on VoteType.AddFundsForStep. It's the amount asked by the team to add on current step
        uint96 askedAmountToAddForStep;

        /// @notice Total of vote power voted in favor of current vote
        uint votePowerInFavorOfProposal;

        /// @notice Total of vote power voted against current vote. This variable is not needed for computation, but used in frontend.
        uint votePowerAgainstProposal;
        
        /// @notice Does the action proposed to vote has been validated
        bool hasVoteBeenValidated;

        /// @notice Flag to know if vote is still running. Mostly used in modifiers
        bool isVoteRunning;
    }

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
        bool isFunded;

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



    /* *********************** 
    *        Variables
    *********************** */

    /// @notice The current project step
    uint8 currentProjectStep;

    /// @notice Flag for case financers has vote to cancel the project
    bool projectGotVoteCanceled;

    /**
    * @notice The total amount requested (sum of project's steps amounts)
    * @dev uint96 stores 600x more than total eth available (in wei unit), should be enough
    */
    uint96 fundingRequested;

    /// @notice Datas of contract. We use a struct to avoid "stack to deep" error in init method
    ProjectData public data;

    /// @notice Map of financers and their donations
    mapping(address => uint96) public financersDonations;

    /// @notice Map of team members. Used for modifiers mostly (reduce gas gost)
    mapping(address => bool) public teamMembersAddresses;

    /// @notice We use this mapping to easily retrieve step by their order number while be able to easily iterate over them
    mapping(uint8 => uint8) public projectStepsOrderedIndex;

    /// @notice List of messages sent by financers & project creator about the project
    Message[] public messages;

    /// @notice Mapping of all votes done
    mapping(uint256 => Vote) votes;

    /// @notice Number of votes. Usefull to iterate over passed votes & get the current vote.
    uint256 currentVoteId;

    /**
    * @notice cumulated vote power of all financers, computed on each fund() method call. 
    * We need to store it that wey as it take some ressources to compute, due to square root.
    */
    uint totalVotePower;



    /* *********************** 
    *        Events
    *********************** */

    /// @notice Event called when a user send a contribution
    event ContributionAddedToProject(address indexed contributor, uint amountInWei);

    /// @notice Event called when the project's balance reaches the requested amount
    event ProjectIsFunded(address indexed contributor, uint fundedAmoutInWei);

    /// @notice Event called when some funds are withdraws
    event FundsWithdrawn(address indexed targetAddress, uint withdrawnAmout);

    /// @notice Event called when a new message is added
    event NewMessage(address indexed writer);

    /// @notice Event called when a financer has vote
    event HasVoted(address indexed voterAddress, uint voteId, bool vote);

    /// @notice Event called when a vote is started
    event VoteStarted(uint indexed voteId, VoteType voteType);

    /// @notice Event called when a vote is ended
    event VoteEnded(uint indexed voteId, bool result);



    /* *********************** 
    *     Custom errors
    *********************** */

    error OwnableUnauthorizedAccount(address account);
    error ProjectHasBeenCanceled();
    error FinancerUnauthorizedAccount(address account);
    error TeamMemberUnauthorizedAccount(address account);
    error FinancerOrTeamMemberUnauthorizedAccount(address account);
    error FundingIsntEndedYet(uint currentDate, uint campaignEndDate);
    error FundingIsEnded(uint currentDate, uint campaignEndDate);
    error OwnableInvalidOwner(address owner);
    error EmptyString(string parameterName);
    error NoVoteRunning();
    error VoteIsAlreadyRunning();
    error AlreadyVoted(address voterAddress);
    error VoteTimeEnded(uint voteTimeEndTimestamp);
    error OnlyTeamMembersCanModifyThisVote();
    error OnlyFinancersCanModifyThisVote();
    error ConditionsForEndingVoteNoteMeetedYet();
    error UseDedicatedMethodToStartAskFundsVote();
    error FundingAmountIsTooLow();
    error ProjectHasntBeenCanceled();
    error ProjectIsFundedYouCantWithdrawNow();
    error ProjectBalanceIsEmpty();
    error ProjectIsntEndedYet();
    error LastStepOfProjectNotValidatedYet();
    error CurrentStepFundsAlreadyWithdrawn();
    error FailWithdrawTo(address to);


    /* *********************** 
    *        Modifiers
    *********************** */

    /// @notice Ensure that only financers can call the function
    modifier onlyFinancer() {
        if (financersDonations[msg.sender] == 0) {
            revert FinancerUnauthorizedAccount(msg.sender);
        }
        _;
    }

    /// @notice Ensure that only team members can call the function
    modifier onlyTeamMember() {
        if (!teamMembersAddresses[msg.sender]) {
            revert TeamMemberUnauthorizedAccount(msg.sender);
        }
        _;
    }

    /// @notice Ensure that only financers of team members can call the function
    modifier onlyTeamMemberOrFinancer() {
        if (financersDonations[msg.sender] == 0 && !teamMembersAddresses[msg.sender]) {
            revert FinancerOrTeamMemberUnauthorizedAccount(msg.sender);
        }
        _;
    }

    /// @notice Ensure that the project's campaign funding end date is passed
    modifier fundingDatePassed {
        if (block.timestamp < data.campaignEndingDateTimestamp) {
            revert FundingIsntEndedYet(block.timestamp, data.campaignEndingDateTimestamp);
        }
        _;
    }

    /// @notice Ensure that the project's campaign functing end date is not passed
    modifier fundingDateNotPassed {
        if (block.timestamp > data.campaignEndingDateTimestamp) {
            revert FundingIsEnded(block.timestamp, data.campaignEndingDateTimestamp);
        }
        _;
    }
    
    /**
    * @notice Ensure that msg.sender can actually start or end a vote of the given type
    *
    * @param voteType The type of vote that user is trying to start / end
    */
    modifier canModifyCurrentVote(VoteType voteType) {
        if (voteType != VoteType.WithdrawProjectToFinancers && !teamMembersAddresses[msg.sender]) {
            revert OnlyTeamMembersCanModifyThisVote();
        } else if (voteType == VoteType.WithdrawProjectToFinancers && financersDonations[msg.sender] == 0) {
            revert OnlyFinancersCanModifyThisVote();
        }

        _;
    }

    /// @notice Ensure that project hasn't been canceled by a vote
    modifier projectHasntBeenCanceled() {
        if (projectGotVoteCanceled) revert ProjectHasBeenCanceled();
        _;
    }

    modifier noVoteIsRunning() {
        if(votes[currentVoteId].isVoteRunning) revert VoteIsAlreadyRunning();
        _;
    }

    modifier voteIsRunning() {
        if (!votes[currentVoteId].isVoteRunning) revert NoVoteRunning();
        _;
    }


    //TODO Check if project is funded everywhere needed

    /* *********************** 
    *        Methods
    *********************** */

    /**
    * @notice As we'll clone this contract, we need to initialize variables here and not in a constructor
    *
    * @param _data We use a struct as a parameter here, to avoid 'stack too deep' error as there as a lot of data.
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

        currentProjectStep = 1;

        _transferOwnership(_data.owner);
    }

    /**
    * @notice Set given address as the new owner.
    * Only the actual owner can call it
    *
    * @param _newOwner The new owner address
    */
    function transferOwner(address _newOwner) public {
        if (data.owner != msg.sender) revert OwnableUnauthorizedAccount(msg.sender);
        _transferOwnership(_newOwner);
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     *
     * @param _newOwner The new owner address
     */
    function _transferOwnership(address _newOwner) internal virtual {
        if (_newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        data.owner = _newOwner;
    }

    /**
     * @notice Method to call by team members, to withdraw funds for the current project step, once it has been validated by financer's vote
     * This allow to unlock project's finances step by step, a process more secure for financers, to avoid scams
     */
    function withdrawCurrentStep() external onlyTeamMember fundingDatePassed projectHasntBeenCanceled nonReentrant {
        ProjectStep storage currentStep = data.projectSteps[projectStepsOrderedIndex[currentProjectStep]];
        if(currentStep.isFunded) revert CurrentStepFundsAlreadyWithdrawn();

        uint96 amountToWithdraw = currentStep.amountNeeded - currentStep.amountFunded;
        currentStep.isFunded = true;
        currentStep.amountFunded += amountToWithdraw;
        
        _safeWithdraw(amountToWithdraw, data.targetWallet);
    }

    /**
     * @notice Method to call by team members, to withdraw funds left for the project once every step has been done and end project date is passed.
     *
     * @dev We don't test if project is canceled here, as if you can't cancel project after the last step has been validated
     */
    function endProjectWithdraw() onlyTeamMember nonReentrant external {
        if(address(this).balance == 0) revert ProjectBalanceIsEmpty();
        if(data.estimatedProjectReleaseDateTimestamp > block.timestamp) revert ProjectIsntEndedYet();
        if(currentProjectStep != data.projectSteps.length 
            || (currentProjectStep == data.projectSteps.length && !data.projectSteps[projectStepsOrderedIndex[currentProjectStep]].hasBeenValidated)) 
            revert LastStepOfProjectNotValidatedYet();

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
        if(checkIfProjectIsFunded()) revert ProjectIsFundedYouCantWithdrawNow();

        uint96 amountToWithdraw = financersDonations[msg.sender];
        financersDonations[msg.sender] = 0;

        _safeWithdraw(amountToWithdraw, msg.sender);
    }

    /**
     * @notice Method to call by financers if a vote set the project as cancaled.
     * This allows financers to get their funding back, minus a potential portail consumed for the projet (depending on current step).
     */
    function withdrawProjectCanceled() external onlyFinancer fundingDatePassed nonReentrant {
       if (!projectGotVoteCanceled) revert ProjectHasntBeenCanceled();

        uint256 PRECISION_FACTOR = 10 ** 12;
        uint256 amountToWithdraw = (uint256(financersDonations[msg.sender]) * address(this).balance * PRECISION_FACTOR) / uint256(data.totalFundsHarvested) / PRECISION_FACTOR;

        //We set donations to 0, to remove this user from financers's list
        financersDonations[msg.sender] = 0;

        _safeWithdraw(amountToWithdraw, msg.sender);
    }


    /**
    * @notice Sends to the given target the amount asked
    * 
    * @param _amountToWithdraw The amount to withdraw, in wei
    * @param _to Address that will receive funds
    */
    function _safeWithdraw(uint _amountToWithdraw, address _to) internal {
        //TODO if fail, transfer in WETH ?
        (bool success, ) = payable(_to).call{value: _amountToWithdraw}("");
        if (!success) revert FailWithdrawTo(_to);
        emit FundsWithdrawn(_to, _amountToWithdraw);
    }


    /**
    * @notice Methods used by users to send some funds to the project.
    * The minimal amount is 1000 wei. 
    * Once a used made a donation, he is considered as a financer, and has vote power.
    */
    function fundProject() external payable fundingDateNotPassed {
        if(msg.value < 1000) revert FundingAmountIsTooLow();
        bool projectWasAlreadyFunded = checkIfProjectIsFunded();
        data.totalFundsHarvested += uint96(msg.value); //TODO Potential loss here, verify if everything can be done in uint256 ?

        // If user has already donated to the project, removing his old vote power to compute the new one later
        if (financersDonations[msg.sender] > 0) {
            totalVotePower -= Maths.sqrt(financersDonations[msg.sender]);
        }

        financersDonations[msg.sender] += uint96(msg.value);
        totalVotePower += Maths.sqrt(financersDonations[msg.sender]);

        emit ContributionAddedToProject(msg.sender, msg.value);
        
        if (checkIfProjectIsFunded() && !projectWasAlreadyFunded) {
            emit ProjectIsFunded(msg.sender, data.totalFundsHarvested);
        }
    }


    /**
    * @notice Method that can be used by team members to ask more funds for the current step.
    * It's only possible if the left balance on the contract is > to sum(amounNeededForFutureSteps)
    *
    * @param amountAsked The amount asked in wei
    */
    function askForMoreFunds(uint amountAsked) external onlyTeamMember fundingDatePassed projectHasntBeenCanceled noVoteIsRunning{
        require((address(this).balance > amountAsked) && (address(this).balance > getSumOfFundsOfLeftSteps()), "You can't ask an amount greater than what's left on balance minus what left to ask for next project steps");

        Vote storage newVote = votes[currentVoteId];
        newVote.voteType = VoteType.AddFundsForStep;
        newVote.endVoteDate = computeVoteEndDate(uint96(block.timestamp));
        newVote.askedAmountToAddForStep = uint96(amountAsked);
        newVote.isVoteRunning = true;

        emit VoteStarted(currentVoteId, VoteType.AddFundsForStep);
    }

    /**
    * @notice Team members or financers can start a vote here (different that 'ask for funds vote' that is special) 
    * 
    * @param voteType The type of vote to start : ValidateStep or WithdrawProjectToFinancers
    */
    function startVote(VoteType voteType) external canModifyCurrentVote(voteType) fundingDatePassed projectHasntBeenCanceled noVoteIsRunning {
        if(voteType == VoteType.AddFundsForStep) revert UseDedicatedMethodToStartAskFundsVote();

        //TODO Can't start vote to cancel project on last step

        Vote storage newVote = votes[currentVoteId];
        newVote.voteType = voteType;
        newVote.endVoteDate = computeVoteEndDate(uint96(block.timestamp));
        newVote.isVoteRunning = true;

        emit VoteStarted(currentVoteId, voteType);
    }

    /**
    * @notice Financers or team members can end vote is conditions are ok.
    * If enough votes are in favor of the proposal, this will be immediatly applied.
    *
    * @dev Don't need to use modifier "projectHasntBeenCanceled" has you can't start a vote if project got canceled
    * Don't need to test if project is in funding phase as you can't start a vote in funding phase
    */
    function endVote() external voteIsRunning canModifyCurrentVote(votes[currentVoteId].voteType){
        Vote storage currentVote = votes[currentVoteId];

        if ((currentVote.endVoteDate > block.timestamp) 
            && ((currentVote.votePowerInFavorOfProposal + currentVote.votePowerAgainstProposal) < totalVotePower)) revert ConditionsForEndingVoteNoteMeetedYet();

        if (isVoteValidated(currentVote.votePowerInFavorOfProposal, totalVotePower)) {
            currentVote.hasVoteBeenValidated = true;
        }

        if (currentVote.hasVoteBeenValidated) {
            if (currentVote.voteType == VoteType.WithdrawProjectToFinancers) projectGotVoteCanceled = true;
            if (currentVote.voteType == VoteType.ValidateStep) {
                data.projectSteps[projectStepsOrderedIndex[currentProjectStep]].hasBeenValidated = true;
                //TODO when going to the next step, take the funds of the last step not withdrawn and add them to the next step ?
                if (currentProjectStep < data.projectSteps.length) currentProjectStep += 1;
            } 
            if (currentVote.voteType == VoteType.AddFundsForStep) {
                data.projectSteps[projectStepsOrderedIndex[currentProjectStep]].isFunded = false;
                data.projectSteps[projectStepsOrderedIndex[currentProjectStep]].amountNeeded += currentVote.askedAmountToAddForStep;
            }
        }

        emit VoteEnded(currentVoteId, currentVote.hasVoteBeenValidated);

        currentVoteId++;
    }

    /**
    * @notice Method that allow financers to vote, if conditions are OK.
    *
    * @dev Don't need to use modifier "projectHasntBeenCanceled" has you can't start a vote if project got canceled
    *
    * @param vote Boolean that user fill to say if he approves or not the proposition.
    */
    function sendVote(bool vote) external onlyFinancer voteIsRunning {
        Vote storage currentVote = votes[currentVoteId];
        if(currentVote.endVoteDate < block.timestamp) revert VoteTimeEnded(currentVote.endVoteDate);
        if(currentVote.hasFinancerVoted[msg.sender]) revert AlreadyVoted(msg.sender);

        if (vote) currentVote.votePowerInFavorOfProposal += Maths.sqrt(financersDonations[msg.sender]);
        else currentVote.votePowerAgainstProposal += Maths.sqrt(financersDonations[msg.sender]);

        currentVote.hasFinancerVoted[msg.sender] = true;
        emit HasVoted(msg.sender, currentVoteId, vote);
    }

    /**
    * @notice Add a message. Message content is store on IPFS, we only keep the CID to retrive content later on the front, to reduce costs.
    *
    * @param ipfsHash The CID of the message content on IPFS
    */
    function addMessage(string calldata ipfsHash) external onlyTeamMemberOrFinancer {
        if(bytes(ipfsHash).length == 0) revert EmptyString("ipfsHash");

        messages.push(Message(msg.sender, ipfsHash, uint32(block.timestamp)));

        emit NewMessage(msg.sender);
    }


    /* *********************** 
    *        Helpers
    *********************** */

    /// @notice Simple mthode to check if the project balance >= asked funds
    function checkIfProjectIsFunded() internal view returns (bool) {
        return data.totalFundsHarvested >= fundingRequested;
    }

    /** 
    * @notice Simple methode to compute end vote date from the start date.
    * We use 3 days as default value.
    *
    * @param timestampStartDate Start date of the vote, in timestamp seconds
    */
    function computeVoteEndDate(uint96 timestampStartDate) internal pure returns(uint96) {
        return timestampStartDate + 3*24*60*60; // Default vote period of 3 days
    }

    /**
    * @notice Simple method to compute the vote result. 
    * We consider the motion approved if 50% or more of the total vote power has approved the motion
    */
    function isVoteValidated(uint _voteInFavorOfProposal, uint _totalVotePower) internal pure returns(bool){
        uint256 PRECISION_FACTOR = 10;
        uint256 percentage = (_voteInFavorOfProposal * PRECISION_FACTOR) / _totalVotePower;

        return percentage >= 5;
    }

    function getSumOfFundsOfLeftSteps() internal view returns(uint) {
        uint ret;

        for (uint i = currentProjectStep; i < data.projectSteps.length; i++) {
            ret += (data.projectSteps[i].amountNeeded - data.projectSteps[i].amountFunded);
        }

        return ret;
    }

    /* *********************** 
    *        Getters
    *********************** */

    function getOwner() external view returns(address) {
        return data.owner;
    }

    function getData() external view returns (ProjectData memory) {
        return data;
    }

    function getMessages() external view returns (Message[] memory) {
        return messages;
    }

    function getCurrentVoteId() external view returns(uint) {
        return currentVoteId;
    }

    function getCurrentVotePower() external view returns (uint) {
        return votes[currentVoteId].votePowerInFavorOfProposal;
    }

    function getCurrentProjectStepId() external view returns (uint) {
        return projectStepsOrderedIndex[currentProjectStep];
    }

    function getCurrentVotePowerAgainstProposal() external view returns (uint) {
        return votes[currentVoteId].votePowerAgainstProposal;
    }

    function isCurrentVoteRunning() external view returns(bool) {
        return votes[currentVoteId].isVoteRunning;
    }

    function getCurrentVoteEndDate() external view returns (uint) {
        return votes[currentVoteId].endVoteDate;
    }

    function getName() external view returns (string memory){
        return data.name;
    }


    /* *********************** 
    *        Payable
    *********************** */

    receive() external payable {}
    fallback() external payable {}
}
