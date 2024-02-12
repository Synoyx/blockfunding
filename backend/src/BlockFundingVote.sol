// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract BlockFundingVote {
    enum VoteType {
        ValidateStep, 
        AddFundsForStep,
        WithdrawProjectToFinancers
    }

    struct Vote {
        uint id;
        VoteType voteType;
        uint96 startVoteDate;
        uint96 endVoteDate;
        
        /// @notice 0 if vote not ended yet, -1 if votes say no, 1 if votes say yes (according to voteType)
        int8 voteResult;
    }


    event HasVoted(address voterAddress, uint voteId, bool vote);
    event VoteStarted(uint voteId, VoteType voteType);
    event VoteEnded(uint voteId, VoteType voteType, bool result);

    modifier canModifyCurrentVote(VoteType voteType) {
        if (voteType != VoteType.WithdrawProjectToFinancers && !isTeamMember) {
            revert("Only team members can use this type of vote");
        } else if (voteType == VoteType.WithdrawProjectToFinancers && !isFinancer) {
            revert("Only financers can use this type of vote");
        }

        _;
    }


    uint idCounter;
    Vote[] public oldVotes;
    Vote public currentVote;
    mapping(address => bool) currentVoteVotes;

    function startVote(VoteType voteType) external canModifyCurrentVote(voteType){
        require(currentVote.id == 0, "A vote is running, you can't start another one for the moment");

        currentVote = Vote(++idCounter, voteType, uint96(block.timestamp), computeVoteEndDate(uint96(block.timestamp)), 0);

        emit VoteStarted(currentVote.id, currentVote.voteType);
    }

    function endVote() external canModifyCurrentVote(currentVote.voteType){
        require(currentVote.id > 0, "There is no vote running, so you can't use this method");
        require(currentVote.endVoteDate > block.timestamp, "Vote's end date isn't passed yet, please wait before ending vote");

        //TODO store vote results (or make it automatically when voting ?)
        //TODO make modifications needed according to votetype & vote results

        oldVotes.push(currentVote);
        emit VoteEnded(currentVote.id, currentVote.voteType, currentVote.voteResult == 1);

        // We reset variable to let new votes happen
        delete currentVote;
    }

    function sendVote(bool vote) external onlyFinancers {
        require(currentVote.id > 0, "There is no vote running, so you can't use this method");
        require(currentVote.endVoteDate < block.timestamp, "Vote time is endend, you can't vote anymore");

        //TODO compute new vote result => Use quadratic voting

        emit HasVoted(msg.sender, currentVote.id, vote);
    }

    function computeVoteEndDate(uint96 timestampStartDate) internal pure returns(uint96) {
        return timestampStartDate + 3*24*60*60; // Default vote period of 3 days
    }
}