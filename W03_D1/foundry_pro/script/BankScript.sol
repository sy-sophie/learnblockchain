// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Script.sol"; // 引入 Foundry 的脚本工具
import "../src/Bank.sol";

contract DeployMyToken is Script {
    function run() external {
        vm.startBroadcast(); // 开始广播交易
        // 部署合约，参数为 Token 名称和符号
        Bank bank = new Bank();
        console.log("Token address:", address(bank));

        // 将 2000 wei 转入 Bank 合约
        (bool success, ) = address(bank).call{value: 2000}("");
        require(success, "Transfer failed"); // 检查转账是否成功

        bank.setAdmin(0x318E1cACDff7DD3414d17d23201b635f486a0F69);
        vm.stopBroadcast(); // 停止广播交易
    }
}

// forge script ./script/BankScript.sol -s "run()" --account privateS4_02 --rpc-url https://ethereum-sepolia-rpc.publicnode.com  --broadcast --verify -vvvv

// safe：sep:0x318E1cACDff7DD3414d17d23201b635f486a0F69

// https://sepolia.etherscan.io/address/0x8690cb51d083e3818894e2465f573964bace2961

// 部署地址：0xBD572FE2928A9eA79c0c029c97dfe73017ca6Ab2
