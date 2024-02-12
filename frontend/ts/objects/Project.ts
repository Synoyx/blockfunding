export enum ProjectCategory {
  Art = "Art",
  Automobile = "Automobile",
  Informatique = "Informatique",
  // Ajoutez autant de catégories que nécessaire
}

export class Project {
  id: number;
  owner: string;
  name: string;
  subtitle: string;
  description: string;
  targetWallet: string;
  fundingRequested: number; // Stocké en Wei
  totalFundsHarvested: number; // Stocké en Wei
  campaignStartingDateTimestamp: number; // Timestamp en secondes
  campaignEndingDateTimestamp: number; // Timestamp en secondes
  estimatedProjectReleaseDateTimestamp: number; // Timestamp en secondes
  projectCategory: ProjectCategory;
  mediasURI: string; // URLs des médias

  constructor(
    id: number,
    owner: string,
    name: string,
    subtitle: string,
    description: string,
    targetWallet: string,
    fundingRequested: number,
    totalFundsHarvested: number,
    campaignStartingDateTimestamp: number,
    campaignEndingDateTimestamp: number,
    estimatedProjectReleaseDateTimestamp: number,
    projectCategory: ProjectCategory,
    mediasURI: string
  ) {
    this.id = id;
    this.owner = owner;
    this.name = name;
    this.subtitle = subtitle;
    this.description = description;
    this.targetWallet = targetWallet;
    this.fundingRequested = fundingRequested;
    this.totalFundsHarvested = totalFundsHarvested;
    this.campaignStartingDateTimestamp = campaignStartingDateTimestamp;
    this.campaignEndingDateTimestamp = campaignEndingDateTimestamp;
    this.estimatedProjectReleaseDateTimestamp = estimatedProjectReleaseDateTimestamp;
    this.projectCategory = projectCategory;
    this.mediasURI = mediasURI;
  }

  describe(): void {
    console.log(`Id: ${this.id}`);
    console.log(`Owner: ${this.owner}`);
    console.log(`Nom: ${this.name}`);
    console.log(`Sous-titre: ${this.subtitle}`);
    console.log(`Description: ${this.description}`);
    console.log(`Adresse du wallet Ethereum: ${this.targetWallet}`);
    console.log(`Objectif de financement (en Wei): ${this.fundingRequested}`);
    console.log(`Date de début: ${new Date(this.campaignStartingDateTimestamp * 1000).toLocaleString()}`);
    console.log(`Date de fin: ${new Date(this.campaignEndingDateTimestamp * 1000).toLocaleString()}`);
    console.log(`Date estimée de réalisation: ${new Date(this.estimatedProjectReleaseDateTimestamp * 1000).toLocaleString()}`);
    console.log(`Catégorie: ${this.projectCategory}`);
    console.log(`Liens du média: ${this.mediasURI}`);
  }
}
