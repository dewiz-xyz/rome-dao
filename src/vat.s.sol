// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Vat} from "dss/vat.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/Vat.s.sol:VatDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract VatDeploy is Script {
    function run() external returns (Vat) {
        vm.startBroadcast();

        Vat tpl = new Vat();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        registry.setContractAddress("Vat", address(tpl));

        vm.stopBroadcast();

        return tpl;
    }
}

//  ./scripts/forge-script.sh ./src/Vat.s.sol:VatInitialize --fork-url=$RPC_URL --broadcast -vvvv
contract VatInitialize is Script {
    function run() external {
        vm.startBroadcast();
        IRegistry registry;
        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        registry = IRegistry(registryAddress);
        address vatAddress = registry.lookUp("Vat");
        address gemjoin = registry.lookUp("GemJoin");
        address dai = registry.lookUp("Dai");

        Vat vat = Vat(vatAddress);
        vat.rely(gemjoin);
        vat.rely(dai);
        vat.init("Denarius-A");
        vat.file("Line", 1_000_000 * 10 ** 45);
        vat.file("Denarius-A", "line", 1_000_000 * 10 ** 45);
        vat.file("Denarius-A", "spot", 1 * 10 ** 27);

        vm.stopBroadcast();
    }
}
