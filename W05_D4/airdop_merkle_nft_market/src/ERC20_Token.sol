// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract NCToken is ERC20, ERC20Permit, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * (10 ** 18);
    constructor() ERC20("NCToken", "NC")ERC20Permit("NCToken") Ownable(msg.sender){
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

}


