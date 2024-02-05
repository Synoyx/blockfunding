export class Project {
  id: number;
  name: string;
  subtitle: string;
  image: string;

  constructor(id: number, name: string, subtitle: string, image: string) {
    this.id = id;
    this.name = name;
    this.subtitle = subtitle;
    this.image = image;
  }

  // Vous pouvez ajouter des méthodes spécifiques à la classe ici, par exemple :
  describe() {
    return `${this.name}: ${this.subtitle}`;
  }
}
