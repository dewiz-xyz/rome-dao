// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {GemJoin} from "dss/join.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {IERC20Metadata} from "./interfaces.sol";

//  ./scripts/forge-script.sh ./src/GemJoin.s.sol:GemJoinDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract GemJoinDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        address vatAddr = registry.lookUp("Vat");
        address denariusAddr = registry.lookUp("Denarius");

        GemJoin gemJoin = new GemJoin(vatAddr, "Denarius-A", denariusAddr);
        registry.setContractAddress("GemJoin", address(gemJoin));

        IERC20Metadata denarius = IERC20Metadata(denariusAddr);
        denarius.approve(address(gemJoin), type(uint256).max);

        vm.stopBroadcast();
    }
}
