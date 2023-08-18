// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Script, console2} from "forge-std/Script.sol";
import {Vat} from "dss/Vat.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {IRegistry} from "./interfaces.sol";
import {Dai} from "dss/dai.sol";
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

    function run() external {
        vm.startBroadcast();
        _setRegistry();
        _deployVat();
        _deployDai();
        _setCollateral();
        _deployGemJoin();
        _deployDaiJoin();
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

//  ./scripts/forge-script.sh ./src/Operation.s.sol:Borrow --fork-url=$RPC_URL --broadcast -vvvv
contract Borrow is Script {
    IRegistry public registry;
    Vat public vat;
    Dai public dai;
    IERC20Metadata public denarius;
    GemJoin public gemJoin;
    DaiJoin public daiJoin;

    function run() external {
        uint256 valueToLock = 12 * 10 ** 18;
        uint256 valueToDrawInDai = 5 * 10 ** 18;

        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        registry = IRegistry(registryAddress);
        gemJoin = GemJoin(registry.lookUp("GemJoin"));
        vat = Vat(registry.lookUp("Vat"));
        daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        dai = Dai(registry.lookUp("Dai"));

        console2.log("Before - I am %s and my balance in Dai: %s", msg.sender, dai.balanceOf(msg.sender));

        gemJoin.join(msg.sender, valueToLock);

        (, uint256 rate, , , ) = vat.ilks("Denarius-A");
        uint256 dart = Numbers.divup(Numbers.mul(Numbers.ray(), valueToDrawInDai), rate);
        require(dart <= 2 ** 255 - 1, "RwaUrn/overflow");
        uint256 dink = dart * 2;

        vat.frob(
            "Denarius-A", // ilk
            msg.sender,
            msg.sender,
            msg.sender, // To keep it simple, use your address for both `u`, `v` and `w`
            int256(dink), // with 10**18 precision
            int256(dart) // with 10**18 precision
        );

        daiJoin.exit(msg.sender, valueToDrawInDai);

        console2.log("dink: %d - dart: %d", dink, dart);
        console2.log("After - I am %s and my balance in Dai: %s", msg.sender, dai.balanceOf(msg.sender));

        vm.stopBroadcast();
    }
}

contract PayBack is Script {
    uint256 public constant _VALUE_TO_PAYBACK = 2 * 10 ** 18;

    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        // gemJoin = GemJoin(registry.lookUp("GemJoin"));
        Vat vat = Vat(registry.lookUp("Vat"));
        Dai dai = Dai(registry.lookUp("Dai"));
        IERC20Metadata denarius = IERC20Metadata(registry.lookUp("Denarius"));
        DaiJoin daiJoin = DaiJoin(registry.lookUp("DaiJoin"));

        daiJoin.join(msg.sender, _VALUE_TO_PAYBACK);
        (, uint256 rate, , , ) = vat.ilks("Denarius-A");
        uint256 dart = Numbers.mul(Numbers.ray(), _VALUE_TO_PAYBACK) / rate;
        uint256 dink = dart * 2;
        require(dart <= 2 ** 255 && dart <= 2 ** 255, "RwaUrn/overflow");

        vat.frob("Denarius-A", msg.sender, msg.sender, msg.sender, -1, -1);

        console2.log("dink: %d - dart: %d", dink, dart);

        uint256 cBalance = dai.balanceOf(msg.sender);
        uint256 cEtherFormat = cBalance / (1 * 10 ** 18);
        console2.log("Dai balance: %d - %d", cEtherFormat, cBalance);

        uint256 dBalance = denarius.balanceOf(msg.sender);
        uint256 dEtherFormat = dBalance / (1 * 10 ** 18);
        console2.log("denarius balance: %d - %d", dEtherFormat, dBalance);

        vm.stopBroadcast();
    }
}

contract InfoBalances is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        IRegistry registry = IRegistry(registryAddress);
        // gemJoin = GemJoin(registry.lookUp("GemJoin"));
        Vat vat = Vat(registry.lookUp("Vat"));
        // daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        Dai dai = Dai(registry.lookUp("Dai"));
        IERC20Metadata denarius = IERC20Metadata(registry.lookUp("Denarius"));

        uint256 cBalance = dai.balanceOf(msg.sender);
        uint256 cEtherFormat = cBalance / (1 * 10 ** 18);
        console2.log("Dai balance: %d - %d", cEtherFormat, cBalance);

        uint256 dBalance = denarius.balanceOf(msg.sender);
        uint256 dEtherFormat = dBalance / (1 * 10 ** 18);
        console2.log("denarius balance: %d - %d", dEtherFormat, dBalance);

        (uint256 ink, uint256 art) = vat.urns("Denarius-A", msg.sender);
        console2.log("vat urn - ink: %d - art: %d", ink, art);

        // solhint-disable-next-line
        (uint256 Art, , , , ) = vat.ilks("Denarius-A");
        console2.log("Total Denarius-A ART: %d", Art);

        vm.stopBroadcast();
    }
}
