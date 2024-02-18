import { TeamMember } from "@/ts/objects/TeamMember";
import { ProjectStep } from "@/ts/objects/ProjectStep";

export enum ProjectCategory {
  Art = "Art",
  Automobile = "Automobile",
  Comics = "Comics",
  Dance = "Dance",
  Design = "Design",
  Faschion = "Fashion",
  Film = "Film",
  Nourriture = "Nourriture",
  Jeux = "Jeux",
  Journalisme = "Journalisme",
  Musique = "Musique",
  Journaux = "Journaux",
  Informatique = "Informatique",
  Theatre = "Theatre",
}

export class Project {
  address: string;
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
    _address: string,
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
    this.address = _address;
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
      "0x0",
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

  toJson(): object {
    return {
      campaignStartingDateTimestamp: this.campaignStartingDateTimestamp,
      campaignEndingDateTimestamp: this.campaignEndingDateTimestamp,
      estimatedProjectReleaseDateTimestamp: this.estimatedProjectReleaseDateTimestamp,
      targetWallet: this.targetWallet,
      owner: this.owner,
      totalFundsHarvested: this.totalFundsHarvested,
      projectCategory: projectCategoryToInt(this.projectCategory),
      name: this.name,
      subtitle: this.subtitle,
      description: this.description,
      mediaURI: this.mediaURI,
      teamMembers: this.teamMembers.map((member) => member.toJson()),
      projectSteps: this.projectSteps.map((step) => step.toJson()),
    };
  }

  describe(): void {
    console.log(`Address: ${this.address}`);
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

function projectCategoryToInt(projectCategory: ProjectCategory): number {
  let ret = 0;

  if (projectCategory == ProjectCategory.Art) ret = 0;
  if (projectCategory == ProjectCategory.Automobile) ret = 1;
  if (projectCategory == ProjectCategory.Comics) ret = 2;
  if (projectCategory == ProjectCategory.Dance) ret = 3;
  if (projectCategory == ProjectCategory.Design) ret = 4;
  if (projectCategory == ProjectCategory.Faschion) ret = 5;
  if (projectCategory == ProjectCategory.Film) ret = 6;
  if (projectCategory == ProjectCategory.Nourriture) ret = 7;
  if (projectCategory == ProjectCategory.Jeux) ret = 8;
  if (projectCategory == ProjectCategory.Journalisme) ret = 9;
  if (projectCategory == ProjectCategory.Musique) ret = 10;
  if (projectCategory == ProjectCategory.Journaux) ret = 11;
  if (projectCategory == ProjectCategory.Informatique) ret = 12;
  if (projectCategory == ProjectCategory.Theatre) ret = 13;

  return ret;
}
