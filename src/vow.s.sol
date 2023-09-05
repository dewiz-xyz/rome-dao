// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Vow} from "dss/vow.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {IERC20Metadata} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/vow.s.sol:VowDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract VowDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address vatAddr = registry.lookUp("Vat");
        address flapperAddr = registry.lookUp("Flapper");
        address flopperAddr = registry.lookUp("Flopper");

        Vow vow = new Vow(vatAddr, flapperAddr, flopperAddr);
        registry.setContractAddress("Vow", address(vow));

        vm.stopBroadcast();
    }
}
