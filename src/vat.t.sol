// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {Vat} from "dss/vat.sol";

contract VatTest is Test {
    Vat internal template;

    function setUp() public {
        template = new Vat();
    }

    function testFailBasicSanity() public {
        assertTrue(false);
    }

    function testBasicSanity() public {
        assertTrue(true);
    }

    function testIsLive() public {
        uint256 isLive = 1;
        uint256 templateLive = uint256(template.live());
        assertEq(templateLive, isLive);
    }
}
