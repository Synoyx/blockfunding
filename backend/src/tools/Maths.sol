// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


library Maths {
    /**
    * @notice Babylonian method for getting square root.
    * It's an approximation, as solidity doesn't handle floating numbers
    */
    function sqrt(uint x) pure internal returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}