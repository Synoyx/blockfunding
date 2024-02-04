// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Strings {
    function compare(string calldata s1, string calldata s2) public pure returns (bool) {
        // Lil gas optimization here
        if (bytes(s1).length != bytes(s2).length) return false;

        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}