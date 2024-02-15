// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/BlockFunding.sol";
import "../src/BlockFundingProject.sol";
import "./tools/MockedData.sol";

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

    /// @dev I add this line to make forge coverage ignore this class
    function test() public virtual {}
}

contract DeployDev is Deploy {
    string[] emptyDynamicArray;

    function getPK() internal view override returns(uint256) {
        return vm.envUint("PRIVATE_KEY_DEV");
    }

    // Here we add some projects to be able to quickly test Blockfunding
    function runCallback(BlockFunding blockFunding) internal override {
        BlockFundingProject.ProjectData[] memory data = MockedData.getMockedProjectDatas();

        for (uint i; i < data.length; i++) {
            blockFunding.createNewProject(data[i]); // Create a clone for each iteration, with given mocked data
        }
    }

    /// @dev I add this line to make forge coverage ignore this class
    function test() public override {}
}

/**
source .env
forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
forge script script/Deploy.s.sol:DeployDev --rpc-url $ANVIL_RPC_URL --broadcast

Get projects
cast call 0xb7f8bc63bbcad18155201308c8f3540b07f84f5e "getProjects()(address[])" --rpc-url $ANVIL_RPC_URL

*/