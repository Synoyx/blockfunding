import { TeamMember } from "@/ts/objects/TeamMember";

export class ProjectData {
  campaignStartingDateTimestamp: number;
  campaignEndingDateTimestamp: number;
  estimatedProjectReleaseDateTimestamp: number;
  targetWallet: string;
  owner: string;
  totalFundsHarvested: BigInt;
  projectCategory: number;
  name: string;
  subtitle: string;
  description: string;
  mediaURI: string;
  teamMembers: TeamMember[];
  projectSteps: ProjectStep[];

  constructor(
    _campaignStartingDateTimestamp: number,
    _campaignEndingDateTimestamp: number,
    _estimatedProjectReleaseDateTimestamp: number,
    _targetWallet: string,
    _owner: string,
    _totalFundsHarvested: BigInt,
    _projectCategory: number,
    _name: string,
    _subtitle: string,
    _description: string,
    _mediaURI: string,
    _teamMembers: TeamMember[],
    _projectSteps: ProjectStep[]
  ) {
    this.campaignStartingDateTimestamp = _campaignStartingDateTimestamp;
    this.campaignEndingDateTimestamp = _campaignEndingDateTimestamp;
    this.estimatedProjectReleaseDateTimestamp = _estimatedProjectReleaseDateTimestamp;
    this.targetWallet = _targetWallet;
    this.owner = _owner;
    this.totalFundsHarvested = _totalFundsHarvested;
    this.projectCategory = _projectCategory;
    this.name = _name;
    this.subtitle = _subtitle;
    this.description = _description;
    this.mediaURI = _mediaURI;
    this.teamMembers = _teamMembers;
    this.projectSteps = _projectSteps;
  }
}

export class ProjectStep {
  name: string;
  description: string;
  amountNeeded: BigInt;
  amountFunded: BigInt;
  isFunded: boolean;
  orderNumber: number;
  hasBeenValidated: boolean;

  constructor(
    _name: string,
    _description: string,
    _amountNeeded: BigInt,
    _amountFunded: BigInt,
    _isFunded: boolean,
    _orderNumber: number,
    _hasBeenValidated: boolean
  ) {
    this.name = _name;
    this.description = _description;
    this.amountNeeded = _amountNeeded;
    this.amountFunded = _amountFunded;
    this.isFunded = _isFunded;
    this.orderNumber = _orderNumber;
    this.hasBeenValidated = _hasBeenValidated;
  }
}
