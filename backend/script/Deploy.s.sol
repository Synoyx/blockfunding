// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";

/**
* @author Julien P.
*/
contract Deploy is Script {
    function getPK() internal view virtual returns(uint256) {
        return vm.envUint("PRIVATE_KEY");
    }

    function runCallback(BlockFunding blockFunding) internal virtual {}

    function run() external {
        uint256 deployerPrivateKey = getPK();
        vm.startBroadcast(deployerPrivateKey);

        BlockFunding blockFunding = new BlockFunding();

        runCallback(blockFunding);

        vm.stopBroadcast();
    }
}

contract DeployDev is Deploy {
    string[] emptyDynamicArray;

    function getPK() internal view override returns(uint256) {
        return vm.envUint("PRIVATE_KEY_DEV");
    }

    // Here we add some projects to be able to quickly test Blockfunding
    function runCallback(BlockFunding blockFunding) internal override {
        blockFunding.createNewContract(
            ["Projet Alpha", "Innovation en Art", "Exploration des frontieres numeriques dans l'art contemporain."],
            emptyDynamicArray,
            [uint(1707210857),uint(1709802857),uint(1725354857),uint(1000000000000000000)],
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            BlockFunding.ProjectCategory.art
        );
        blockFunding.createNewContract(
            ["Eco Drive", "Revolution Automobile", "Une approche durable de la mobilite urbaine."],
            emptyDynamicArray,
            [uint(1707210857),uint(1709802857),uint(1725354857),uint(1000000000000000000)],
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            BlockFunding.ProjectCategory.automobile
        );
        blockFunding.createNewContract(
            ["Tech Innovate", "Avancee en Informatique", "Developpement d'un nouveau systeme d'exploitation base sur la securite."],
            emptyDynamicArray,
            [uint(1707210857),uint(1709802857),uint(1725354857),uint(1000000000000000000)],
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            BlockFunding.ProjectCategory.software
        );
    }
}

/**
source .env
forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
forge script script/Deploy.s.sol:DeployDev --rpc-url $ANVIL_RPC_URL --broadcast

Get projects
cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getProjects()(address[])" --rpc-url $ANVIL_RPC_URL

*/