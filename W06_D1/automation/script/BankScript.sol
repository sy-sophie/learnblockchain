// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "../src/Bank.sol";

contract BankScript is Script {
    // 0xFF：一个常数，避免和CREATE冲突
    // CreatorAddress: 调用 CREATE2 的当前合约（创建合约）地址。0xaFf04833F098F2EebDDe71C0c49aCb298743eD29
    // salt（盐）：一个创建者指定的bytes32类型的值，它的主要目的是用来影响新创建的合约的地址。
    // initcode: 新合约的初始字节码（合约的Creation Code和构造函数的参数）。
    bytes32 constant SALT = bytes32(uint256(0x0000000000000000000000000000000000000000000000000000000000000001));


    function run() public {
        // private key
//        uint256 deployerPrivateKey = vm.envUint("privateS4");
        // get the deployer's address from the private key
//        address deployerAddress = vm.addr(deployerPrivateKey); // 0xaFf04833F098F2EebDDe71C0c49aCb298743eD29

        vm.startBroadcast();

        // Create2 deploy
        Bank newBank = new Bank{ salt: SALT }( 10);

        console2.log("Bank deployed to:", address(newBank));
//        console2.log("Deployed by:", deployerAddress);

        vm.stopBroadcast();
    }
}

//  https://sepolia.etherscan.io/address/0x260de9af708b1f9092dd5b876dbe6ffa059cfd90
