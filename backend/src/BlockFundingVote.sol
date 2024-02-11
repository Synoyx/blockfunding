// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract BlockFundingVote {
    enum VoteType {
        ValidateStep, 
        AddFundsForStep,
        ValidateProject,
        WithdrawProjectToFinancers,
        WithdrawProjectToTeamMembers
    }

    struct Vote {
        VoteType voteType;
        uint96 startVoteDate;
        uint96 endVoteDate;
        mapping(address => bool) votes;
        
        /// @notice 0 if vote not ended yet, -1 if votes say no, 1 if votes say yes (according to voteType)
        int8 voteResult;
    }

    Vote[] public oldVotes;
    Vote public currentVote;

    function startVote(VoteType voteType) external {
        //TODO check if, in function of voteType, msg.sender can start it.
        //TODO check if currentVote is empty
        //TODO create new Vote object, and store it
        //TODO emit event
    }

    function endVote() external {
        //TODO check if, un function of voteType, msg.sender can end it
        //TODO store vote results (or make it automatically when voting ?)
        //TODO check if date is passed
        //TODO store vote in oldVotes
        //TODO make modifications needed according to votetype & vote results
        //TODO emit event
    }

    function vote() external {
        //TODO check if msg.sender can vote according to voteType & msg.sender role (financer, teammember, other)
        //TODO check if a vote is currently running & endDate isn't passed
        //TODO compute new vote result
        //TODO emit event
    }
}