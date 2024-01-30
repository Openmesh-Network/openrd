// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 private number;

    function getNumber() external view virtual returns (uint256) {
        return number;
    }

    function setNumber(uint256 newNumber) external virtual {
        number = newNumber;
    }

    function increment() external virtual {
        number++;
    }
}
