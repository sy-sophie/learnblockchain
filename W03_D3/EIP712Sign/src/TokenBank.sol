// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ITokenBank.sol";
import "./MyToken.sol";

contract TokenBank is ITokenBank {
    mapping (address => uint) public balances;
    address public admin;
    MyToken public token;


    constructor(MyToken _token) {
        admin = msg.sender;
        token = _token; // 初始化 Token 合约地址
    }

    function deposite(uint256 amount) public payable  override {
        require(amount > 0, "Deposit amount must be greater than zero");
        token.transferFrom(msg.sender, address(this), amount); // 从用户转移 Token 到合约
        balances[msg.sender] += amount; // 更新用户的存入数量
    }
    function withdraw() public returns (uint){
        require(msg.sender == admin, "Only admin can withdraw all tokens");
        uint totalBalance = token.balanceOf(address(this)); // 获取合约的总余额

        require(totalBalance > 0, "No tokens available for withdrawal");

        token.transfer(admin, totalBalance); // 提取所有 Token 到管理员地址
        return totalBalance;
    }

    function permitDeposit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override payable {
        token.permit(owner, spender, value, deadline, v, r, s);
        token.transferFrom(owner, spender, value);
        balances[spender] += value;
    }

    function getBalance(address user) public view returns (uint) {
        return balances[user];
    }
}
