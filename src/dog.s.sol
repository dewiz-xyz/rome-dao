// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Dog} from "dss/dog.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {IERC20Metadata} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/dog.s.sol:DogDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract DogDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address vatAddr = registry.lookUp("Vat");

        Dog dog = new Dog(vatAddr);
        registry.setContractAddress("Dog", address(dog));

        vm.stopBroadcast();
    }
}

//  ./scripts/forge-script.sh ./src/dog.s.sol:DogBark --fork-url=$RPC_URL --broadcast -vvvv
contract DogBark is Script {
    function run() external {
        vm.startBroadcast();
        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address dogAddr = registry.lookUp("Dog");
        Dog dog = Dog(dogAddr);
        dog.bark("Denarius-A", msg.sender, address(0x2E69508520ed70Bd227bcb8fa68865F1F0756c12));
    }
}
