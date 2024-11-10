// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BankLinkedStorage.sol";

contract BankLinkedStorageTest is Test {
    BankLinkedStorage bank;

    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);
    address user4 = address(0x4);
    address user5 = address(0x5);
    address user6 = address(0x6);
    address user7 = address(0x7);
    address user8 = address(0x8);
    address user9 = address(0x9);
    address user10 = address(0xa);
    address user11 = address(0xb);

    function setUp() public {
        bank = new BankLinkedStorage();
    }

    function testGetTopUsers() public {
        uint depositAmount1 = 1 ether;
        uint depositAmount2 = 2 ether;
        uint depositAmount3 = 3 ether;
        uint depositAmount4 = 4 ether;
        uint depositAmount5 = 5 ether;
        uint depositAmount6 = 6 ether;
        uint depositAmount7 = 7 ether;
        uint depositAmount8 = 8 ether;
        uint depositAmount9 = 9 ether;
        uint depositAmount10 = 10 ether;
        uint depositAmount11 = 11 ether;

        vm.deal(user1, depositAmount1);
        vm.deal(user2, depositAmount2);
        vm.deal(user3, depositAmount3);
        vm.deal(user4, depositAmount4);
        vm.deal(user5, depositAmount5);
        vm.deal(user6, depositAmount6);
        vm.deal(user7, depositAmount7);
        vm.deal(user8, depositAmount8);
        vm.deal(user9, depositAmount9);
        vm.deal(user10, depositAmount10);
        vm.deal(user11, depositAmount11);

        vm.prank(user1);
        bank.deposit{value: depositAmount1}();
        vm.prank(user2);
        bank.deposit{value: depositAmount2}();
        vm.prank(user3);
        bank.deposit{value: depositAmount3}();
        vm.prank(user4);
        bank.deposit{value: depositAmount4}();
        vm.prank(user5);
        bank.deposit{value: depositAmount5}();
        vm.prank(user6);
        bank.deposit{value: depositAmount6}();
        vm.prank(user7);
        bank.deposit{value: depositAmount7}();
        vm.prank(user8);
        bank.deposit{value: depositAmount8}();
        vm.prank(user9);
        bank.deposit{value: depositAmount9}();
        vm.prank(user10);
        bank.deposit{value: depositAmount10}();
        vm.prank(user11);
        bank.deposit{value: depositAmount11}();

        address[10] memory topDepositors = bank.getTopUsers();
        assertEq(topDepositors[0], user11);
        assertEq(topDepositors[1], user10);
        assertEq(topDepositors[2], user9);
    }

}
