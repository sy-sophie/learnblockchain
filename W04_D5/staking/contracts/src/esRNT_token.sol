// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ESRNToken is ERC20, Ownable {
    struct LockInfo {
        address user;
        uint256 amount;
        uint256 lockTime;
    }
    LockInfo[] public locks;

    IERC20 public rntToken;
    event Minted(address indexed _user, uint256 _amount, uint256 lockId);

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * (10 ** 18);
    constructor(IERC20 _rntToken) ERC20("esRNToken", "esRNT") Ownable(msg.sender){
        rntToken = _rntToken;
//        _transferOwnership(msg.sender);  需要转移所有权
    }

    function mint(address to, uint256 amount) external onlyOwner {
        transferFrom(address(this), to, amount); // 产生 esRNT 给 user
        locks.push(LockInfo({
            user: to,
            amount: amount,
            lockTime: block.timestamp // or  block.timestamp + 30 days
        }));
        uint256 lockId = locks.length - 1;
        emit Minted( to, amount, lockId);
    }

    function burn(uint256 lockId) public {
        require(lockId<locks.length, "Invalid lockId");
        LockInfo storage lock = locks[lockId];
        require(lock.user == msg.sender, "Not the owner of the lock");

        uint256 unlocked = (lock.amount*(block.timestamp - lock.lockTime))/30 days;

        uint256 burnAmount= lock.amount-unlocked;

        _burn(msg.sender, lock.amount);
        rntToken.transfer(msg.sender, unlocked);
        rntToken.transfer(address(0), burnAmount);
    }
    function getLocksByUser(address user) external view returns (LockInfo[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].user == user) {
                count++;
            }
        }

        LockInfo[] memory userLocks = new LockInfo[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].user == user) {
                userLocks[index] = locks[i];
                index++;
            }
        }
        return userLocks;
    }
}


