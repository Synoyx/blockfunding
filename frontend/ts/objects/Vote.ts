export enum VoteType {
  ValidateStep,
  AddFundsForStep,
  WithdrawProjectToFinancers,
}

export class Vote {
  stepNumber: bigint;
  askedAmountToAddForStep: bigint;
  endVoteDate: bigint;
  hasVoteBeenValidated: boolean;
  isVoteRunning: boolean;
  voteType: VoteType;
  hasFinancerVoted: boolean;
  votePowerInFavorOfProposal: bigint;
  votePowerAgainstProposal: bigint;
  totalVotePower: bigint;

  constructor(
    _stepNumber: bigint,
    _askedAmountToAddForStep: bigint,
    _endVoteDate: bigint,
    _hasVoteBeenValidated: boolean,
    _isVoteRunning: boolean,
    _voteType: VoteType,
    _hasFinancerVoted: boolean,
    _votePowerInFavorOfProposal: bigint,
    _votePowerAgainstProposal: bigint,
    _totalVotePower: bigint
  ) {
    this.stepNumber = _stepNumber;
    this.askedAmountToAddForStep = _askedAmountToAddForStep;
    this.endVoteDate = _endVoteDate;
    this.hasVoteBeenValidated = _hasVoteBeenValidated;
    this.isVoteRunning = _isVoteRunning;
    this.voteType = _voteType;
    this.hasFinancerVoted = _hasFinancerVoted;
    this.votePowerInFavorOfProposal = _votePowerInFavorOfProposal;
    this.votePowerAgainstProposal = _votePowerAgainstProposal;
    this.totalVotePower = _totalVotePower;
  }

  static createEmpty(): Vote {
    return new Vote(
      0n,
      0n,
      BigInt(Math.floor(Date.now() / 1000)), // Utilise Date.now() pour obtenir le timestamp actuel en secondes
      false,
      false,
      VoteType.AddFundsForStep, // Vous pouvez choisir une valeur par défaut appropriée pour votre cas d'utilisation
      false,
      0n,
      0n,
      0n
    );
  }

  canVoteBeEnded(): boolean {
    return (
      this.endVoteDate < new Date().getTime() / 1000 ||
      this.votePowerInFavorOfProposal + this.votePowerAgainstProposal == this.totalVotePower
    );
  }

  canUserEndVote(isTeamMember: boolean, isFinancer: boolean): boolean {
    return (
      (this.voteType != VoteType.WithdrawProjectToFinancers && isTeamMember) ||
      (this.voteType == VoteType.WithdrawProjectToFinancers && isFinancer)
    );
  }
}
