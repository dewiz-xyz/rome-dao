// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import {Dai} from "dss/dai.sol";

//Dai test
contract DaiTest is Test {
    Dai internal _dai;
    address public sender;

    function setUp() public {
        sender = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
        _dai = new Dai(1337);
        _dai.mint(sender, 1000 * 10 ** uint256(_dai.decimals()));
    }

    function testFailBasicSanity() public {
        assertTrue(false);
    }

    function testBasicSanity() public {
        assertTrue(true);
    }

    function testBalance() public {
        uint256 supposedBalance = 1000 * 10 ** uint256(_dai.decimals());
        uint256 balance = _dai.balanceOf(sender);
        console2.log("Balances: %d - %d", supposedBalance, balance);
        assertEq(supposedBalance, balance);
    }
}
