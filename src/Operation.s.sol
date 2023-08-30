// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Vat} from "dss/Vat.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {Dai} from "dss/dai.sol";
import {Dog} from "dss/dog.sol";
import {Spotter} from "dss/spot.sol";
import {Clipper} from "dss/clip.sol";
import {IERC20Metadata} from "./interfaces.sol";
import {GemJoin, DaiJoin} from "dss/join.sol";

//  ./scripts/forge-script.sh ./src/Operation.s.sol:Setup --fork-url=$RPC_URL --broadcast -vvvv
contract Setup is Script {
    IRegistry public registry;
    Vat public vat;
    Dai public dai;
    IERC20Metadata public denarius;
    GemJoin public gemJoin;
    DaiJoin public daiJoin;
    Dog public dog;
    Spotter public spot;
    Clipper public clip;

    function run() external {
        vm.startBroadcast();
        _setRegistry();
        _deployVat();
        _deployDai();
        _setCollateral();
        _deployGemJoin();
        _deployDaiJoin();
        _deployDog();
        _deploySpotter();
        _deployClipper();
        _vatInitialization();
        vm.stopBroadcast();
    }

    function _setRegistry() internal {
        (, address registryAddress) = RegistryUtil.getRegistryAddress();
        registry = IRegistry(registryAddress);
    }

    function _deployVat() internal {
        vat = new Vat();
        registry.setContractAddress("Vat", address(vat));
    }

    function _deployDai() internal {
        dai = new Dai(1337);
        registry.setContractAddress("Dai", address(dai));
    }

    function _setCollateral() internal {
        denarius = IERC20Metadata(registry.lookUp("Denarius"));
    }

    function _deployGemJoin() internal {
        gemJoin = new GemJoin(address(vat), "Denarius-A", address(denarius));
        registry.setContractAddress("GemJoin", address(gemJoin));
        denarius.approve(address(gemJoin), type(uint256).max);
    }

    function _deployDaiJoin() internal {
        daiJoin = new DaiJoin(address(vat), address(dai));
        registry.setContractAddress("DaiJoin", address(daiJoin));
        dai.approve(address(daiJoin), type(uint256).max);
        dai.rely(address(daiJoin));
        vat.hope(address(daiJoin));
    }

    function _deployDog() internal {
        dog = new Dog(address(vat));
        registry.setContractAddress("Dog", address(dog));
    }

    function _deploySpotter() internal {
        spot = new Spotter(address(vat));
        registry.setContractAddress("Spotter", address(spot));
    }

    function _deployClipper() internal {
        clip = new Clipper(address(vat), address(spot), address(dog), "Denarius-A");
        registry.setContractAddress("Clipper", address(clip));
    }

    function _vatInitialization() internal {
        uint256 price = 1;
        uint256 numDigitsBelowOneAndPositive = 0;
        vat.rely(address(gemJoin));
        vat.rely(address(dai));
        vat.init("Denarius-A");
        vat.file("Line", 1_000_000 * 10 ** 45);
        vat.file("Denarius-A", "line", 1_000_000 * 10 ** 45);
        // vat.file("Denarius-A", "spot", 1 * 10**27);
        vat.file(
            "Denarius-A",
            "spot",
            Numbers.convertToInteger(price, Numbers.rayDecimals(), numDigitsBelowOneAndPositive)
        ); //Actual price of MATIC 2023-08-16 - 0.616 USD
    }
}

//  ./scripts/forge-script.sh ./src/Operation.s.sol:RegistryInfo --fork-url=$RPC_URL --broadcast -vvvv

contract RegistryInfo {
    IRegistry public registry;

    function _setRegistry() internal {
        (, address registryAddress) = RegistryUtil.getRegistryAddress();
        registry = IRegistry(registryAddress);
    }

    function run() external {
        _setRegistry();
        console2.log("Dog Address: %s", registry.lookUp("Dog"));
        console2.log("Spotter Address: %s", registry.lookUp("Spotter"));
        console2.log("Clipper Address: %s", registry.lookUp("Clipper"));
    }
}
