// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Counter} from "./Counter.sol";

contract ProxyCounter is Counter {
    Counter private immutable proxyCounter;

    constructor(Counter counter) {
        proxyCounter = counter;
    }

    function getNumber() external view override returns (uint256) {
        return proxyCounter.getNumber();
    }

    function setNumber(uint256 newNumber) external override {
        proxyCounter.setNumber(newNumber);
    }

    function increment() external override {
        proxyCounter.increment();
    }
}
