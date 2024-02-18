export class TeamMember {
  firstName: string;
  lastName: string;
  description: string;
  photoLink: string;
  role: string;
  walletAddress: string;

  constructor(_firstName: string, _lastName: string, _description: string, _photoLink: string, _role: string, _walletAddress: string) {
    this.firstName = _firstName;
    this.lastName = _lastName;
    this.description = _description;
    this.photoLink = _photoLink;
    this.role = _role;
    this.walletAddress = _walletAddress;
  }

  toJson(): object {
    return {
      firstName: this.firstName,
      lastName: this.lastName,
      description: this.description,
      photoLink: this.photoLink,
      role: this.role,
      walletAddress: this.walletAddress,
    };
  }
}
