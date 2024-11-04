// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RNToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * (10 ** 18); // 初始供应量为 100 万个代币
    constructor() ERC20("RNToken", "RNT") Ownable(msg.sender){
        _mint(msg.sender, INITIAL_SUPPLY); // 将初始供应量分配给合约的拥有者
    }

    // 允许合约拥有者在需要时增发代币，方便后续的扩展需求
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

}


