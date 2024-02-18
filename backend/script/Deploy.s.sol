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

        console.log(string.concat("Contract address = ", toString(abi.encodePacked(address(blockFunding)))));
    }

    /// @dev I add this line to make forge coverage ignore this class
    function test() public virtual {}

    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
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
cast call 0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0 "getProjects()(BlockFundingProject.ProjectData[])" --rpc-url $ANVIL_RPC_URL
cast call 0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0 "getProjectsAddresses()" --rpc-url $ANVIL_RPC_URL

*/