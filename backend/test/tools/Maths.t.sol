// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";


import "../../src/tools/Maths.sol";

contract MathsTest is Test {
    function test_sqrtResult() external {
        assertEq(Maths.sqrt(9), 3, "Result of sqrt function seems not correct");
        assertEq(Maths.sqrt(27), 5, "Result of sqrt function seems not correct");
        assertEq(Maths.sqrt(70), 8, "Result of sqrt function seems not correct");
        assertEq(Maths.sqrt(1), 1, "Result of sqrt function seems not correct");
        assertEq(Maths.sqrt(0), 0, "Result of sqrt function seems not correct");
        assertEq(Maths.sqrt(123456789), 11111, "Result of sqrt function seems not correct");
    }
}
