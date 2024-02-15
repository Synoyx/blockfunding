// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";


import "../../script/Deploy.s.sol";
import "../../script/tools/MockedData.sol";
import "../../src/BlockFunding.sol";

/**
* Theese 'tests' are useless, as I usually don't test scripts.
* But to get the 100% coverage with `forge coverage`command, I need to do that, as I can't ignore some files for coverage ...
*/
contract DeployTest is Test {
    Deploy deploy = new Deploy();

    function test_run() external {
        deploy.run();
    }
}

contract DeployDevTest is Test {
    DeployDev deploy = new DeployDev();

    function test_run() external {
        deploy.run();
    }
}
