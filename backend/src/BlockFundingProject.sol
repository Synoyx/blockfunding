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
        /// @notice Step number the amount has been asked for
        uint96 stepNumber;

        /// @notice Variable only use on VoteType.AddFundsForStep. It's the amount asked by the team to add on current step
        uint96 askedAmountToAddForStep;
        
        /// @notice End vote date, in timestamp second format
        uint96 endVoteDate;

        /// @notice Does the action proposed to vote has been validated
        bool hasVoteBeenValidated;

        /// @notice Flag to know if vote is still running. Mostly used in modifiers
        bool isVoteRunning;

        /// @notice Type of vote (see enum comment for more details)
        VoteType voteType;

        /// @notice Mapping to keep a trace of who has voted
        mapping (address => bool) hasFinancersVoted;

        /// @notice Total of vote power voted in favor of current vote
        uint votePowerInFavorOfProposal;

        /// @notice Total of vote power voted against current vote. This variable is not needed for computation, but used in frontend.
        uint votePowerAgainstProposal;
    }

    struct SimplifiedVote {
        /// @notice Step number the amount has been asked for
        uint96 stepNumber;

        /// @notice Variable only use on VoteType.AddFundsForStep. It's the amount asked by the team to add on current step
        uint96 askedAmountToAddForStep;
        
        /// @notice End vote date, in timestamp second format
        uint96 endVoteDate;

        /// @notice Does the action proposed to vote has been validated
        bool hasVoteBeenValidated;

        /// @notice Flag to know if vote is still running. Mostly used in modifiers
        bool isVoteRunning;

        /// @notice Type of vote (see enum comment for more details)
        VoteType voteType;

        /// @notice Does the used has voted
        bool hasFinancerVoted;

        /// @notice Total of vote power voted in favor of current vote
        uint votePowerInFavorOfProposal;

        /// @notice Total of vote power voted against current vote. This variable is not needed for computation, but used in frontend.
        uint votePowerAgainstProposal;

        /// @notice Total vote power (of the contract)
        uint totalVotePower;
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
    uint8 currentProjectStepId;

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
    error AmountAskedTooHigh();
    error CantCancelProjectAtTheLastStep();
    error TargetWalletSameAsTeamMember();
    error GivenTargetWalletAddressIsEmpty();
    error MissingInformationForTeamMember();
    error ProjectIsntFunded();


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

    modifier projectFunded {
        if (block.timestamp < data.campaignEndingDateTimestamp || !checkIfProjectIsFunded()) {
            revert ProjectIsntFunded();
        }
        _;
    }

    /// @notice Ensure that the project's campaign funding end date is not passed
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

        // Max nb team members & project steps

        for (uint i; i < _data.teamMembers.length; i++) {
            if (_data.teamMembers[i].walletAddress == _data.targetWallet) revert TargetWalletSameAsTeamMember();
            if (_data.teamMembers[i].walletAddress == address(0)) revert GivenTargetWalletAddressIsEmpty();
            if (bytes(_data.teamMembers[i].firstName).length == 0 
                || bytes(_data.teamMembers[i].lastName).length == 0 
                || bytes(_data.teamMembers[i].description).length == 0 
                || bytes(_data.teamMembers[i].photoLink).length == 0 
                || bytes(_data.teamMembers[i].firstName).length == 0) revert MissingInformationForTeamMember();

            data.teamMembers.push(_data.teamMembers[i]);
            teamMembersAddresses[_data.teamMembers[i].walletAddress] = true;
        }

        for (uint i; i < _data.projectSteps.length; i++) {
            ProjectStep memory step = ProjectStep(
                 _data.projectSteps[i].name,
                 _data.projectSteps[i].description,
                 _data.projectSteps[i].amountNeeded,
                 0,
                 false,
                 _data.projectSteps[i].orderNumber,
                 false
            );

            data.projectSteps.push(step);
            projectStepsOrderedIndex[_data.projectSteps[i].orderNumber] = uint8(i);
            fundingRequested += _data.projectSteps[i].amountNeeded;
        }

        currentProjectStepId = 1;

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
    * @notice This function is mostly added for demo purpose.
    * It allows to shorten the campaign period, unlocking two scenarios : withdrawProjectNotFunded, if project hasn't been funded, and startVote if project is funded
    */
    function endFundingCampaign() external onlyTeamMember {
        data.campaignEndingDateTimestamp = uint32(block.timestamp -1);
    }

    /**
     * @notice Method to call by team members, to withdraw funds for the current project step, once it has been validated by financer's vote
     * This allow to unlock project's finances step by step, a process more secure for financers, to avoid scams
     */
    function withdrawCurrentStep() external onlyTeamMember projectFunded projectHasntBeenCanceled nonReentrant {
        ProjectStep storage currentStep = data.projectSteps[projectStepsOrderedIndex[currentProjectStepId]];
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
     * We don't check if the project is funded, as we already check current step, and you can't change step without project being funded
     */
    function endProjectWithdraw() onlyTeamMember nonReentrant external {
        if(address(this).balance == 0) revert ProjectBalanceIsEmpty();
        if(data.estimatedProjectReleaseDateTimestamp > block.timestamp) revert ProjectIsntEndedYet();
        if(currentProjectStepId != data.projectSteps.length 
            || (currentProjectStepId == data.projectSteps.length && !data.projectSteps[projectStepsOrderedIndex[currentProjectStepId]].hasBeenValidated)) 
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
     *
     * @dev We don't check if project has been funded as a vote for canceling project can't happen if it's not funded
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
        data.totalFundsHarvested += uint96(msg.value);

        // Removing his old vote power to compute the new one later. If user did'nt fund yet, won't change anything as sqrt(0) = 0
        totalVotePower -= Maths.sqrt(financersDonations[msg.sender]);

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
    function askForMoreFunds(uint amountAsked) external onlyTeamMember projectFunded projectHasntBeenCanceled noVoteIsRunning {
        if((address(this).balance < amountAsked) || (address(this).balance < (getSumOfFundsOfLeftSteps() + amountAsked))) revert AmountAskedTooHigh();

        Vote storage newVote = votes[currentVoteId];
        newVote.voteType = VoteType.AddFundsForStep;
        newVote.endVoteDate = computeVoteEndDate(uint96(block.timestamp));
        newVote.askedAmountToAddForStep = uint96(amountAsked);
        newVote.stepNumber = currentProjectStepId;
        newVote.isVoteRunning = true;

        emit VoteStarted(currentVoteId, VoteType.AddFundsForStep);
    }

    /**
    * @notice Team members or financers can start a vote here (different that 'ask for funds vote' that is special) 
    * 
    * @param voteType The type of vote to start : ValidateStep or WithdrawProjectToFinancers
    */
    function startVote(VoteType voteType) external canModifyCurrentVote(voteType) projectFunded projectHasntBeenCanceled noVoteIsRunning {
        if(voteType == VoteType.AddFundsForStep) revert UseDedicatedMethodToStartAskFundsVote();
        if (voteType == VoteType.WithdrawProjectToFinancers 
            && currentProjectStepId == data.projectSteps.length 
            && data.projectSteps[currentProjectStepId - 1].hasBeenValidated) revert CantCancelProjectAtTheLastStep();

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
    * Don't need to test if project is in funding phase as you can't start a vote in funding phase. Same thing for is project funded
    */
    function endVote() external voteIsRunning canModifyCurrentVote(votes[currentVoteId].voteType){ 
        Vote storage currentVote = votes[currentVoteId];

        if ((currentVote.endVoteDate > block.timestamp) 
            && ((currentVote.votePowerInFavorOfProposal + currentVote.votePowerAgainstProposal) < totalVotePower)) revert ConditionsForEndingVoteNoteMeetedYet();

        if (isVoteValidated(currentVote.votePowerInFavorOfProposal, totalVotePower)) {
            currentVote.hasVoteBeenValidated = true;
            ProjectStep storage curProjectStep = data.projectSteps[projectStepsOrderedIndex[currentProjectStepId]];

            if (currentVote.voteType == VoteType.WithdrawProjectToFinancers) { projectGotVoteCanceled = true; }
            else if (currentVote.voteType == VoteType.ValidateStep) {
                curProjectStep.hasBeenValidated = true;
                if (currentProjectStepId < data.projectSteps.length) { currentProjectStepId += 1;}
            } 
            else if (currentVote.voteType == VoteType.AddFundsForStep) {
                curProjectStep.isFunded = false;
                curProjectStep.amountNeeded += currentVote.askedAmountToAddForStep;
            }
        }

        emit VoteEnded(currentVoteId, currentVote.hasVoteBeenValidated);

        currentVoteId++;
    }

    /**
    * @notice Method that allow financers to vote, if conditions are OK.
    *
    * @dev Don't need to use modifier "projectHasntBeenCanceled" has you can't start a vote if project got canceled
    * Same thing for isProjectFunded
    *
    * @param vote Boolean that user fill to say if he approves or not the proposition.
    */
    function sendVote(bool vote) external onlyFinancer voteIsRunning {
        Vote storage currentVote = votes[currentVoteId];
        if(currentVote.endVoteDate < block.timestamp) revert VoteTimeEnded(currentVote.endVoteDate);
        if(currentVote.hasFinancersVoted[msg.sender]) revert AlreadyVoted(msg.sender);

        currentVote.votePowerInFavorOfProposal += vote ? Maths.sqrt(financersDonations[msg.sender]) : 0;
        currentVote.votePowerAgainstProposal += vote ? 0 : Maths.sqrt(financersDonations[msg.sender]);

        currentVote.hasFinancersVoted[msg.sender] = true;
        emit HasVoted(msg.sender, currentVoteId, vote);
    }

    /**
    * @notice Add a message. Message content is store on IPFS, we only keep the CID to retrive content later on the front, to reduce costs.
    *
    * @param ipfsHash The CID of the message content on IPFS
    */
    function addMessage(string calldata ipfsHash) external onlyTeamMemberOrFinancer {
        // Max X messages par jour pour ce user ? 
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

        for (uint i = currentProjectStepId; i < data.projectSteps.length; i++) {
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

    function getFundingRequested() external view returns (uint) {
        return fundingRequested;
    }

    function getCurrentProjectStepId() external view returns (uint) {
        return currentProjectStepId;
    }

    function getCurrentProjectStepIndex() external view returns (uint) {
        return projectStepsOrderedIndex[currentProjectStepId];
    }

    function getCurrentVotePowerAgainstProposal() external view returns (uint) {
        return votes[currentVoteId].votePowerAgainstProposal;
    }

    function isCurrentVoteRunning() external view returns(bool) {
        return votes[currentVoteId].isVoteRunning;
    }

    function isLastVoteValidated() external view returns (bool) {
        uint currentId = currentVoteId > 0 ? currentVoteId - 1 : 0;
        return votes[currentId].hasVoteBeenValidated;
    }

    function getCurrentVoteEndDate() external view returns (uint) {
        return votes[currentVoteId].endVoteDate;
    }

    function getName() external view returns (string memory){
        return data.name;
    }

    function getTotalVotePower() external view returns (uint) {
        return totalVotePower;
    }

    function getCurrentVote(address userAddress) external view returns (SimplifiedVote memory) {
        Vote storage currentVote = votes[currentVoteId];

        SimplifiedVote memory ret = SimplifiedVote(
            currentVote.stepNumber,
            currentVote.askedAmountToAddForStep,
            currentVote.endVoteDate,
            currentVote.hasVoteBeenValidated,
            currentVote.isVoteRunning,
            currentVote.voteType,
            currentVote.hasFinancersVoted[userAddress],
            currentVote.votePowerInFavorOfProposal,
            currentVote.votePowerAgainstProposal,
            totalVotePower
        );

        return ret;
    }

    function getFinancerDonationAmount(address financerAddress) external view returns (uint) {
        return financersDonations[financerAddress];
    }

    function isProjectCanceled() external view returns (bool) {
        return projectGotVoteCanceled;
    }

    function isProjectCanceledOrLastStepValidated() external view returns (bool) {
        return projectGotVoteCanceled || (currentProjectStepId == data.projectSteps.length 
            && data.projectSteps[currentProjectStepId - 1].hasBeenValidated);
    }

    function isFinancer(address userAddress) external view returns (bool) {
        return financersDonations[userAddress] > 0;
    }

    function isWithdrawCurrentStepAvailable() external view returns (bool) {
        bool isTeamMember = teamMembersAddresses[msg.sender];
        bool isProjectFunded = block.timestamp > data.campaignEndingDateTimestamp && checkIfProjectIsFunded();
        bool isCurrentStepFunded = data.projectSteps[projectStepsOrderedIndex[currentProjectStepId]].isFunded;

        return isTeamMember && isProjectFunded && !projectGotVoteCanceled && !isCurrentStepFunded;
    }


    function isWithdrawEndProjectAvailable(address userAddress) external view returns (bool) {
        bool isTeamMember = teamMembersAddresses[userAddress];
        bool isBalancePositive = address(this).balance > 0;
        bool isProjectEnded = block.timestamp > data.estimatedProjectReleaseDateTimestamp;
        bool isLastStepValidated = currentProjectStepId == data.projectSteps.length && data.projectSteps[projectStepsOrderedIndex[currentProjectStepId]].hasBeenValidated;

        return isTeamMember && isBalancePositive && isProjectEnded && isLastStepValidated;
    }

    function isWithdrawProjectNotFundedAvailable(address userAddress) external view returns (bool) {
        bool isUserFinancer = financersDonations[userAddress] > 0;
        bool isProjectFunded = checkIfProjectIsFunded();
        bool isCampaignEnded = block.timestamp > data.campaignEndingDateTimestamp;

        return isUserFinancer && !isProjectFunded && isCampaignEnded;
    }

    function isWithdrawProjectCanceledAvailable(address userAddress) external view returns (bool) {
        bool isUserFinancer = financersDonations[userAddress] > 0;
        bool isCampaignEnded = block.timestamp > data.campaignEndingDateTimestamp;

        return isUserFinancer && isCampaignEnded && projectGotVoteCanceled;
    }

    /* *********************** 
    *        Payable
    *********************** */

    receive() external payable {}
}
