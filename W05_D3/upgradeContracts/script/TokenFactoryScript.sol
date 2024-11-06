// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import  "forge-std/Script.sol";
import "../src/TokenFactory.sol";

contract TokenFactoryScript is Script {
    function run() public {
        vm.startBroadcast();
        TokenFactoryUpgradeable tokenFactoryUpgradeable = new TokenFactoryUpgradeable();
        TokenFactoryUpgradeableV2 tokenFactoryUpgradeableV2 = new TokenFactoryUpgradeableV2();
        vm.stopBroadcast();
    }
}
