export enum ProjectCategory {
  Art = "Art",
  Automobile = "Automobile",
  Informatique = "Informatique",
  // Ajoutez autant de catégories que nécessaire
}

export class Project {
  id: number;
  name: string;
  subtitle: string;
  description: string;
  walletAddress: string;
  fundingGoal: string; // Stocké en Wei
  startDate: number; // Timestamp en secondes
  endDate: number; // Timestamp en secondes
  estimatedCompletionDate: number; // Timestamp en secondes
  category: ProjectCategory;
  mediaLinks: string[]; // URLs des médias

  constructor(
    id: number,
    name: string,
    subtitle: string,
    description: string,
    walletAddress: string,
    fundingGoal: string,
    startDate: number,
    endDate: number,
    estimatedCompletionDate: number,
    category: ProjectCategory,
    mediaLinks: string[]
  ) {
    this.id = id;
    this.name = name;
    this.subtitle = subtitle;
    this.description = description;
    this.walletAddress = walletAddress;
    this.fundingGoal = fundingGoal;
    this.startDate = startDate;
    this.endDate = endDate;
    this.estimatedCompletionDate = estimatedCompletionDate;
    this.category = category;
    this.mediaLinks = mediaLinks;
  }

  describe(): void {
    console.log(`Id: ${this.id}`);
    console.log(`Nom: ${this.name}`);
    console.log(`Sous-titre: ${this.subtitle}`);
    console.log(`Description: ${this.description}`);
    console.log(`Adresse du wallet Ethereum: ${this.walletAddress}`);
    console.log(`Objectif de financement (en Wei): ${this.fundingGoal}`);
    console.log(`Date de début: ${new Date(this.startDate * 1000).toLocaleString()}`);
    console.log(`Date de fin: ${new Date(this.endDate * 1000).toLocaleString()}`);
    console.log(`Date estimée de réalisation: ${new Date(this.estimatedCompletionDate * 1000).toLocaleString()}`);
    console.log(`Catégorie: ${this.category}`);
    console.log(`Liens des médias: ${this.mediaLinks.join(", ")}`);
  }
}
