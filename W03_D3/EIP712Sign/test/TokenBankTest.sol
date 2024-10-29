// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/TokenBank.sol";
import "../utils/SigUtils.sol";


contract TokenBankTest is Test {
    MyToken internal token;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;

    address internal owner;
    TokenBank internal spender; // bank

    uint256 initialSupply = 1000 * 10 ** 18;


    function setUp() public {
        token = new MyToken(initialSupply);
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;

        owner = vm.addr(ownerPrivateKey);
        spender = new TokenBank(token);

        token.transfer(owner, initialSupply);
    }

    function testPermitDeposit() public {
        uint256 depositAmount = 30000; // 要存入的金额
        uint256 deadline = block.timestamp + 1 days; // 设置许可的截止时间
        uint256 nonce = token.nonces(owner); // 获取用户的 nonce

        // 创建许可数据
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(spender),
            value: depositAmount,
            nonce: nonce,
            deadline: deadline
        });

        console.log("owner address:", owner);
        console.log("Deposit amount:", depositAmount);
        console.log("Nonce:", nonce);
        console.log("Deadline:", deadline);

        // 计算哈希并签名
        bytes32 typedDataHash = sigUtils.getTypedDataHash(permit);
        console.log("Typed data hash:", uint256(typedDataHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, typedDataHash);
        console.log("Signature v:", uint256(v));
        console.log("Signature r:", uint256(r));
        console.log("Signature s:", uint256(s));

        // 使用许可进行存款
        vm.prank(owner);
        spender.permitDeposit(owner,  depositAmount, deadline, v, r, s);

        // 验证 spender 的余额
        console.log("token.balanceOf(owner)", token.balanceOf(owner));
        assertEq(token.balanceOf(owner), initialSupply - 30000);

        assertEq(spender.getBalance(owner), depositAmount);
        console.log("spender balance after deposit:", spender.getBalance(owner));

    }
}

