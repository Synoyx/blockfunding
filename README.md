![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white) ![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white) ![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white) ![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white) ![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB) ![Next JS](https://img.shields.io/badge/Next-black?style=for-the-badge&logo=next.js&logoColor=white) ![Chakra](https://img.shields.io/badge/chakra-%234ED1C5.svg?style=for-the-badge&logo=chakraui&logoColor=white)

# BlockFunding

Final project for Alyra's course

This project is a crowdfunding platform, based on the blockchain.
BlockFunding allows you to create crowdfunding campaigns who establish confidence with funders, as transparency is one of the main key, and the project gives power to financers by allowing them do directly impact the project by voting (DAO).

## Access links

[Video link](https://www.loom.com/share/1c630936fede4aca9e80ed7f221c7584?sid=8d39024c-8249-4397-9102-84cde62bcbfd)

<!-- [DApp link](http://blockfunding-one.vercel.app) -->

The smart contract is deployed on Sepolia network [Etherscan link](https://sepolia.etherscan.io/address/0xeed7b2565a5a89f6bfc80fa3688777fcea507dc3)

## Must read before continuing

Before using the DApp, you must know that smart contracts of this project are highly secured, and one of the main security mecanism is time. This implies that you won't be able to quickly execute all the differents functionnalities of the app (See security part for more details).
In fact, to be able to realize a meanigful demo for you, I had to make two modification, that I'd not let on a real production deployment :

- I added a method to manually change the endFundingCampaignDate to now(), otherwise I'd need to wait at least 7 days to be able to show you methods like vote & withdraw
- I removed a limitation around the startFundingCampaignDate. This date can (for the demo) be in the past, so I can easily inject projects in different status
  The two modification should now be taken in account security wise, because as I said I added this only for the demo, and I know that theese methods bring a potential DoS security breach

## Getting started

If you want to run the project localy, here are the commands that you need :

#### Before deploying

The DApp will automaticaly switch between local node and sepolia chain, base on the `NODE_ENV`variable (if development env => local node, otherwise sepolia)).
A deploy script is available in `backend/script/Deploy.s.sol`. Before using it, you must follow these steps :

- Create a file `.env` in backend folder
- Add this line : `SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY` to be able to deploy on sepolia
- Add this line `ANVIL_RPC_URL=http://127.0.0.1:8545`to deploy on local node
- If you want to verify the contract, when you deploy on sepolia, get an etherscan api key, and add this line to the file : `ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY`
- Deploy script will use a seperate private key depending if you deploy for dev purpose or production. For production, add this line : `PRIVATE_KEY=YOUR_WALLET_PK_STARTING_WITH_0x`. For dev purpose, add this line `PRIVATE_KEY_DEV=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`. You can use this PK, it's one of the default one of anvil

#### Deploy commands

```sh
  git clone https://github.com/Synoyx/blockfunding.git

  cd blockfunding/backend
  forge test # this will install all the necessary dependencies and ensure all tests are OK

  source .env # load values in terminal
  forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv # If you want to deploy with 'production' mode, on sepolia, and verify contract
  forge script script/Deploy.s.sol:DeployDev --rpc-url $ANVIL_RPC_URL --broadcast # If you want to deploy with 'dev' mode (with already added mocked data) on local onde
  # Don't forget to first launch your local node first ! anvil command in a separated terminal from backend folder will do the trick

  # When you run the script, one of the first output line will give you the deployed contract address. Copy the contract's address ('Contract address =  0xXXXXXXXXX...)
  # Paste this value in the file PROJECT_ROOT/frontend/ts/constants.js.

  # Run the DApp
  cd ../frontend
  npm i
  npx next
```

## Backend

#### Security

Here are the measures taken to enhance the security of smart contracts:

- **Withdraw:** adherence to the "Withdrawal pattern" (check/change state/withdraw) to reduce reentrancy risks. Utilization of OpenZeppelin's ReentrancyGuard and the call method, in the same vein of security.

- **Force feeding:** to avoid the force feeding vulnerability, which could be more impactful since the vote is quadratic, important calculations are not based on the contract's balance but on internal variables. However, the balance is used for final withdrawals, to avoid leaving any potential leftover funds in the contract if a force feeding attempt was made.

- **Use of wei:** Since Solidity does not support floats, the amounts manipulated were deliberately kept in wei. The main purpose of this is the redistribution of funds to financiers in case a project is canceled by a vote. This redistribution must be done pro rata to each one's donations and the amounts already committed by the project, thus the use of division is mandatory. The use of amounts in wei & a very high precision factor (10^12) helps to avoid potential operational flaws.

- **Simplicity:** To avoid slightly more complex attacks, such as oracle manipulation, functions have been simplified as much as possible. Similarly, front running is not possible due to the nature of the functions. Votes are not manipulable because they are considered "false" by default (thus no action to be taken), and only the project's financiers can vote (knowing that one cannot become a financier when votes are available).

- **Arrays:** The use of arrays is very strongly limited, in favor of mappings, to avoid DoS gas limit. To reduce the risks of DoS attacks on the few existing arrays, certain measures have been taken:

  - **Array 'projects' in 'BlockFunding.sol':** A DoS is possible here, by trying to fill the array to the maximum to paralyze the DApp. However, a limitation has been put in place: an owner of an ongoing contract cannot create another contract. This means that the attacker would have to use a different address for each contract creation, and pay the contract creation fees + ETH transfer to this new address. Knowing that it would take several hundred thousand entries before impacting the application, that this array being mainly in read mode the impact would be minor, and that each project having its own smart contract, and thus not impacted by this potential problem, this array is considered secure.

  - **Array 'teamMembers' & 'projectStep' in 'BlockFundingProject.sol':** These arrays are unmodifiable, are limited in number of items upon their creation, and used only at the creation of the contract corresponding to the new project.

  - **Array 'messages':** to be able to add a message, one must be part of the project team, or be one of its financiers. A daily limit of messages has been set per user, combined with the fact that a crowdfunding project has its own message array & the fact that the platform is only useful during the crowdfunding campaign and the realization of the project, a user with this daily limit would need several years before being able to impact the DApp.

#### Before running tests

Before running tests, you'll need to install the dependencies.
For foundry, you'll need to run the following command : `forge install OpenZeppelin/openzeppelin-contracts`

#### Test politic

Each main method has been tested.
Tests are most of the time organised as follow :

- Testing normal case
- Testing events
- Testing cases with different inputs
- Testing all cases thet revert

Most of getters aren't tested, as they're used in other methods. There still are some getter tested, as they're used nowhere else.

#### Test coverage

As shown on image below, tests cover 100% of lines / statements / branches / funcs.
You can test this with the command `forge coverage` in the backend folder

![Test coverage image](https://image.noelshack.com/fichiers/2024/07/7/1708268684-capture-d-ecran-2024-02-18-a-16-04-33.png)

#### Unit test results

There is a total of 102 unit tests, to cover the whole code base.
In the current state, all the 102 unit tests are valid.
You can test this with the command `forge test` in the backend folder

![Unit test results](https://image.noelshack.com/fichiers/2024/07/7/1708268754-capture-d-ecran-2024-02-18-a-16-05-39.png)

Stack used:

- Typescript
- React with NextJS
- Chakra.ui
- Rainbowkit
- Wagmi

#### Roles

There are 3 roles in the DApp

- Visitor : A user connected user. Can fund projets (and become financer of the project), and create new projects
- Financer : A user that has financed a project. A User can be financer of multiple projects. Financers can vote on each project thei're financers of. They can also withdraw on certain circumstances, start vote, and end vote
- Team member : A user that is declared as a team member of a project (based on wallet). A team member can launch votes, end votes and withdraw fund (to the project's wallet)

#### Usability

As said earlier, I ensure that the user can only access to screens & functionnalities corresponding to his role.
Requests to the blockchain are pretty slow. To make our app more userfriendly, I added loading screen everywhere it's needed.
As metamask's popup can sometimes not appear by itself, I added a modal message when the app is waiting for transaction to be signed, telling the user to check metamask.

#### Readability

I chose to stick with a simple design and high contrast betwen the main 2 colors. The only exception is with rainbowkit, as is was not possible to customize everything (on their doc, they advise to use only their themes' options, as the rest is unstable).  
Each screen remains epurated and only the necessary information is displayed.
