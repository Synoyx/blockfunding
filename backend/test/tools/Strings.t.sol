// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";


import "../../src/tools/Strings.sol";

contract StringsTest is Test {
    function test_bytes32ToString() external {
        bytes32 bytesString = bytes32("Hello world");

        assertEq(Strings.bytes32ToString(bytesString), "Hello world", "Bytes32 to string conversion doesn't work");
    }
    function test_bytes32ToStringWithEmptyString() external {
        bytes32 bytesString = bytes32("");

        assertEq(Strings.bytes32ToString(bytesString), "", "Bytes32 to string conversion doesn't work");
    }

    function test_compareString() external {
        assertEq(Strings.compare("Toto", "Tata"), false, "Strings comparison doesn't work");
        assertEq(Strings.compare("Toto", "Toto"), true, "Strings comparison doesn't work");
    }

    function test_compareStringWithDifferentLength() external {
        assertEq(Strings.compare("Toto", "Very long string ..."), false, "Strings comparison doesn't work");
    }
}
