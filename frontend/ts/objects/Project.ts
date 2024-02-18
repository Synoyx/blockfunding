import { TeamMember } from "@/ts/objects/TeamMember";
import { ProjectStep } from "@/ts/objects/ProjectStep";

export enum ProjectCategory {
  Art = "Art",
  Automobile = "Automobile",
  Informatique = "Informatique",
}

export class Project {
  campaignStartingDateTimestamp: number; // In timestamp seconds
  campaignEndingDateTimestamp: number; // In timestamp seconds
  estimatedProjectReleaseDateTimestamp: number; // In timestamp seconds
  targetWallet: string;
  owner: string;
  totalFundsHarvested: number; //Stored in Wei
  projectCategory: ProjectCategory;
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
    _totalFundsHarvested: number,
    _projectCategory: ProjectCategory,
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

  static createEmpty(): Project {
    return new Project(
      Math.round(new Date().getTime() / 1000 + 1 * 24 * 60 * 60),
      Math.round(new Date().getTime() / 1000 + 8 * 24 * 60 * 60),
      Math.round(new Date().getTime() / 1000 + 15 * 24 * 60 * 60),
      "",
      "",
      0,
      ProjectCategory.Art,
      "",
      "",
      "",
      "",
      [],
      []
    );
  }

  getTotalFundsRequested(): bigint {
    let ret: any = 0n;

    for (let projectStep of this.projectSteps) {
      ret = ret + projectStep.amountNeeded;
    }

    return ret;
  }

  toJsonTest(): object {
    return {
      campaignStartingDateTimestamp: this.campaignStartingDateTimestamp,
      campaignEndingDateTimestamp: this.campaignEndingDateTimestamp,
      estimatedProjectReleaseDateTimestamp: this.estimatedProjectReleaseDateTimestamp,
      targetWallet: this.targetWallet,
      owner: this.owner,
      totalFundsHarvested: this.totalFundsHarvested,
      projectCategory: 0,
      name: this.name,
      subtitle: this.subtitle,
      description: this.description,
      mediaURI: this.mediaURI,
      teamMembers: this.teamMembers.map((member) => member.toJson()),
      projectSteps: this.projectSteps.map((step) => step.toJson()),
    };
  }

  describe(): void {
    console.log(`Owner: ${this.owner}`);
    console.log(`Nom: ${this.name}`);
    console.log(`Sous-titre: ${this.subtitle}`);
    console.log(`Description: ${this.description}`);
    console.log(`Adresse du wallet Ethereum: ${this.targetWallet}`);
    console.log(`Date de début: ${new Date(this.campaignStartingDateTimestamp * 1000).toLocaleString()}`);
    console.log(`Date de fin: ${new Date(this.campaignEndingDateTimestamp * 1000).toLocaleString()}`);
    console.log(`Date estimée de réalisation: ${new Date(this.estimatedProjectReleaseDateTimestamp * 1000).toLocaleString()}`);
    console.log(`Catégorie: ${this.projectCategory}`);
    console.log(`Liens du média: ${this.mediaURI}`);
  }
}
