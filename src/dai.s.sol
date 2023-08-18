// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Dai} from "dss/dai.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/dai.s.sol:DaiDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract DaiDeploy is Script {
    function run() external {
        vm.startBroadcast();
        Dai dai = new Dai(1337);

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("not instanciate the registry");
        }
        IRegistry registry = IRegistry(registryAddress);
        registry.setContractAddress("Dai", address(dai));

        vm.stopBroadcast();
    }
}
