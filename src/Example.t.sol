// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import {Example} from "./Example.sol";

contract ExampleTest is Test {
    Example internal template;

    function setUp() public {
        template = new Example(0);
    }

    function testFailBasicSanity() public {
        assertTrue(false);
    }

    function testBasicSanity() public {
        assertTrue(true);
    }
}
