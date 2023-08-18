// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {Example} from "./Example.sol";

contract ExampleDeploy is Script {
    function run() external returns (Example) {
        vm.startBroadcast();

        Example tpl = new Example(1);

        vm.stopBroadcast();

        return tpl;
    }
}
