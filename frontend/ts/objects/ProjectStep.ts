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
