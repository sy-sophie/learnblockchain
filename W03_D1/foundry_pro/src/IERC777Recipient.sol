// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC777Recipient {
    function tokensReceived( // 允许 接收者 在接收代币时执行自定义逻辑 这个函数在 ERC777 代币合约调用 send 或 transfer 后自动触发，确保代币接收者可以处理接收到的代币
        address operator, // 代币持有者地址 || 操作的代理方
        address from,
        address to,
        uint256 amount,
        bytes calldata userData, // 用户提供的附加数据
        bytes calldata operatorData // 操作员提供的附加数据
    ) external;
}
