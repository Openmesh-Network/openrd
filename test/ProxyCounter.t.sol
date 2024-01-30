// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {ProxyCounter} from "../src/ProxyCounter.sol";

contract ProxyCounterTest is Test {
    Counter public counter;
    ProxyCounter public proxyCounter;

    function setUp() public {
        counter = new Counter();
        proxyCounter = new ProxyCounter(counter);
    }

    function invariant_GetNumber() public {
        assertEq(counter.getNumber(), proxyCounter.getNumber());
    }
}
