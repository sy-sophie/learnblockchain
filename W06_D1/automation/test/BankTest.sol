// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;

    address user = address(0x123);
    address owner = address(0x456);

    function setUp() public {
        vm.startPrank(owner);
        bank = new Bank(20);
        vm.deal(owner, 100 ether);
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.deal(user, 10 ether); // 给用户10个Ether
        vm.prank(user); // 模拟用户调用
        bank.deposit{value: 10 ether}();
        assertEq(bank.getTotalDeposits(), 10 ether);
    }

    function testAutomatedTransfer() public {
        vm.deal(user, 2000 ether); // 给用户2000个Ether
        vm.prank(user);
        bank.deposit{value: 2000 ether}();

        assertEq(bank.getTotalDeposits(), 2000 ether);

        vm.warp(block.timestamp + 21);
        (bool upkeepNeeded,) = bank.checkUpkeep(new bytes(0)); // 获取是否需要执行任务
        assertTrue(upkeepNeeded, "Upkeep should be needed"); // 确保自动化任务需要执行

        vm.prank(bank.owner());
        bank.performUpkeep(new bytes(0));
        uint256 remainingDeposits = bank.getTotalDeposits();
        console.log(remainingDeposits, "remainingDeposits");
        assertEq(remainingDeposits, 1000 ether);

    }
}

