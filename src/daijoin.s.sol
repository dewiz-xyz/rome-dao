// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {DaiJoin} from "dss/join.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {Dai} from "dss/dai.sol";
import {Vat} from "dss/vat.sol";

//  ./scripts/forge-script.sh ./src/DaiJoin.s.sol:DaiJoinDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract DaiJoinDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address vat = registry.lookUp("Vat");
        address dai = registry.lookUp("Dai");

        DaiJoin tpl = new DaiJoin(vat, dai);

        registry.setContractAddress("DaiJoin", address(tpl));

        vm.stopBroadcast();
    }
}

//  ./scripts/forge-script.sh ./src/DaiJoin.s.sol:DaiJoinReceiveAllowance --fork-url=$RPC_URL --broadcast -vvvv
contract DaiJoinReceiveAllowance is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address daiJoinAddress = registry.lookUp("DaiJoin");
        address daiAddress = registry.lookUp("Dai");
        address vatAddress = registry.lookUp("Vat");

        Dai dai = Dai(daiAddress);
        Vat vat = Vat(vatAddress);

        dai.approve(daiJoinAddress, type(uint256).max);
        dai.rely(daiJoinAddress);
        vat.hope(daiJoinAddress);

        vm.stopBroadcast();
    }
}
