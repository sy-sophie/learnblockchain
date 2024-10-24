// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ITokenBank {
    function deposite(uint256 amount) external payable;

    function withdraw() external returns (uint);

    function permitDeposit(
        address owner,   // 代币持有者地址
        address spender, // 被授权的地址
        uint256 value,   // 授权的代币数量
        uint256 deadline,// 签名截止时间
        uint8 v,         // 签名参数，恢复参数，用于恢复签名者的公钥
        bytes32 r,       // 签名参数，签名的前 32 字节部分
        bytes32 s        // 签名参数，签名的后 32 字节部分
    ) external payable;
    // 帮用户做了 _approve(owner, spender, value);
}
