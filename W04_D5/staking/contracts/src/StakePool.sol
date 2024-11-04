// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./esRNT_token.sol";
import "./RNT_token.sol";

contract StakePool is ReentrancyGuard {
    RNToken public rntToken;
    ESRNToken public esrntToken;
    uint256 public rewardRate=1 ether;

    struct StakeInfo {
        uint256 staked;    // 用户质押的 RNT 数量
        uint256 unclaimed; // 用户未领取的奖励
        uint256 lastUpdateTime; // 上次奖励更新的时间
    }
    mapping(address => StakeInfo) public stakes;
    event Staked(address indexed user, uint256 amount);  // 记录用户质押操作
    event Unstaked(address indexed user, uint256 amount);// 记录用户解押操作
    event Claimed(address indexed user, uint256 reward); // 记录用户领取奖励操作
    event Burned(address indexed user, uint256 amount); // 记录用户燃烧操作

    constructor(address _rntToken, address _esrntToken) {
        rntToken = RNToken(_rntToken);
        esrntToken = ESRNToken(_esrntToken);
    }
    // 用户质押函数
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0"); // 检查质押数量是否大于 0
        updateReward(msg.sender); // 更新用户的奖励
        rntToken.transferFrom(msg.sender, address(this), amount);  // 将用户的 RNT 代币转移到合约地址
        stakes[msg.sender].staked += amount; // 增加用户的质押数量

        emit Staked(msg.sender, amount); // 触发质押事件
    }

    // 用户解押函数
    function unstake(uint256 amount) external {
        require(stakes[msg.sender].staked >= amount, "Insufficient staked amount"); // 检查用户质押数量是否足够
        updateReward(msg.sender); // 更新用户的奖励
        stakes[msg.sender].staked -= amount; // 减少用户的质押余额并将 RNT 代币转回给用户
        rntToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount); // 触发解押事件
    }

    // 用户领取奖励函数
    function claim() external {
        updateReward(msg.sender); // 更新用户奖励
        uint256 reward = stakes[msg.sender].unclaimed; // 获取用户未领取的奖励
        require(reward > 0, "No reward to claim"); // 检查是否有可领取的奖励
        stakes[msg.sender].unclaimed = 0; // 重置未领取的奖励

        esrntToken.mint(msg.sender, reward); // 将 esrntToken 代币转给用户

        emit Claimed(msg.sender, reward); // 触发领取奖励事件
    }

    // 更新用户的奖励
    function updateReward(address user) internal {
        uint256 timeDiff = block.timestamp - stakes[user].lastUpdateTime; // 计算自上次更新以来的时间差
        stakes[user].unclaimed += (stakes[user].staked * rewardRate * timeDiff) / 1 days; // 根据质押数量和时间增加未领取的奖励
        stakes[user].lastUpdateTime = block.timestamp; // 更新用户的上次更新时间
    }
}
