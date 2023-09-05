// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Flopper} from "dss/flop.sol";
import {GemJoin} from "dss/join.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {IERC20Metadata} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/flop.s.sol:FlopperDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract FlopperDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address vatAddr = registry.lookUp("Vat");
        address gemJoinAddr = registry.lookUp("GemJoin");

        Flopper flop = new Flopper(vatAddr, gemJoinAddr);
        registry.setContractAddress("Flopper", address(flop));

        vm.stopBroadcast();
    }
}
