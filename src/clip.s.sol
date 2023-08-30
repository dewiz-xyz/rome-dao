// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Clipper} from "dss/clip.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {IERC20Metadata} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/clip.s.sol:ClipperDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract ClipperDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address vatAddr = registry.lookUp("Vat");
        address spotAddr = registry.lookUp("Spotter");
        address dogAddr = registry.lookUp("Dog");

        Clipper clip = new Clipper(vatAddr, spotAddr, dogAddr, "Denarius-A");
        registry.setContractAddress("Clipper", address(clip));

        vm.stopBroadcast();
    }
}
