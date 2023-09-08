// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Vat} from "dss/vat.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/vat.s.sol:VatDeploy --fork-url=$RPC_URL --broadcast -vvvv
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

//  ./scripts/forge-script.sh ./src/vat.s.sol:VatInitialize --fork-url=$RPC_URL --broadcast -vvvv
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

//  ./scripts/forge-script.sh ./src/vat.s.sol:VatInfo --fork-url=$RPC_URL --broadcast -vvvv
contract VatInfo is Script {
    struct Ilk {
        uint256 Art; // Total Normalised Debt     [wad]
        uint256 rate; // Accumulated Rates         [ray]
        uint256 spot; // Price with Safety Margin  [ray]
        uint256 line; // Debt Ceiling              [rad]
        uint256 dust; // Urn Debt Floor            [rad]
    }

    function run() external returns (bool) {
        vm.startBroadcast();
        IRegistry registry;
        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        registry = IRegistry(registryAddress);
        Vat vat = Vat(registry.lookUp("Vat"));
        Ilk memory temp;
        console2.log("");
        console2.log("Denarius A - Ilks:");
        (temp.Art, temp.rate, temp.spot, temp.line, temp.dust) = vat.ilks("Denarius-A");
        console2.log("Denarius-A - Art: %s", temp.Art);
        console2.log("Denarius-A - rate: %s", temp.rate);
        console2.log("Denarius-A - spot: %s", temp.spot);
        console2.log("Denarius-A - line: %s", temp.line);
        console2.log("Denarius-A - dust: %s", temp.dust);

        console2.log("");
        console2.log("Denarius B - Ilks:");
        (temp.Art, temp.rate, temp.spot, temp.line, temp.dust) = vat.ilks("Denarius-B");
        console2.log("Denarius-B - Art: %s", temp.Art);
        console2.log("Denarius-B - rate: %s", temp.rate);
        console2.log("Denarius-B - spot: %s", temp.spot);
        console2.log("Denarius-B - line: %s", temp.line);
        console2.log("Denarius-B - dust: %s", temp.dust);
        return true;
    }
}
