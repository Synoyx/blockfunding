export class ProjectStep {
  name: string;
  description: string;
  amountNeeded: number;
  amountFunded: number;
  isFunded: boolean;
  orderNumber: number;
  hasBeenValidated: boolean;

  constructor(
    _name: string,
    _description: string,
    _amountNeeded: number,
    _amountFunded: number,
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

  toJson(): string {
    return JSON.stringify({
      name: this.name,
      description: this.description,
      amountNeeded: this.amountNeeded,
      amountFunded: this.amountFunded,
      isFunded: this.isFunded,
      orderNumber: this.orderNumber,
      hasBeenValidated: this.hasBeenValidated
    });
  }
}
