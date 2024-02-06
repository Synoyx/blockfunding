// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/BlockFunding.sol";

/**
* @author Julien P.
*/
contract Deploy is Script {
    function getPK() internal virtual returns(uint256) {
        return vm.envUint("PRIVATE_KEY");
    }

    function run() external {
        uint256 deployerPrivateKey = getPK();
        vm.startBroadcast(deployerPrivateKey);

        BlockFunding blockFunding = new BlockFunding();

        vm.stopBroadcast();
    }
}

contract DeployDev is Deploy {
    function getPK() internal override returns(uint256) {
        return vm.envUint("PRIVATE_KEY_DEV");
    }
}

/**
source .env
forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
forge script script/Deploy.s.sol:DeployDev --rpc-url $ANVIL_RPC_URL --broadcast
*/