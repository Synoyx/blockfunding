// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/BlockFunding.sol";

/**
* @author Julien P.
*/
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        BlockFunding blockFunding = new BlockFunding();

        vm.stopBroadcast();
    }
}