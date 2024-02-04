// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Strings {
    function compare(string calldata s1, string calldata s2) public pure returns (bool) {
        // Lil gas optimization here
        if (bytes(s1).length != bytes(s2).length) return false;

        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
}