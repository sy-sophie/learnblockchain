// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyWalletNew.sol";

contract MyWalletNewTest is Test {
    MyWalletNew public wallet;

    address public owner = address(0x123);
    address public newOwner = address(0x456);

    function setUp() public {
        wallet = new MyWalletNew("Test Wallet");
    }
    function testTransferOwnershipByOwner() public {
        assertEq(wallet.owner(), address(this)); // 检查初始的 owner 地址


        vm.prank(owner); // 确保只能由当前的 owner 调用 transferOwnership
        wallet.transferOwernship(newOwner);

        assertEq(wallet.owner(), newOwner); // 确保 ownership 被成功转移
    }

}
