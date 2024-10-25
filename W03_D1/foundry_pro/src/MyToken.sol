// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyToken is ERC20, ERC20Permit {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") ERC20Permit("MyToken"){
        _mint(msg.sender, initialSupply);
    }
    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}



