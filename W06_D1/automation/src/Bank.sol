// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AutomationCompatibleInterface.sol";
import "forge-std/Test.sol";

contract Bank is AutomationCompatibleInterface {
    address public owner;
    mapping(address => uint256) public deposits;
    uint256 public threshold;
    uint256 public totalDeposits;

    uint256 public counter; // 每次自动化任务执行时，计数器将递增

    uint256 public immutable interval; // 用于设置间隔时间（单位：秒）
    uint256 public lastTimeStamp; // 上次自动化任务执行的时间戳

    event Deposit(address indexed user, uint256 amount);
    event AutomatedTransfer(address indexed to, uint256 amount);

    constructor(uint256 updateInterval) {
        interval = updateInterval;  // 设置每次自动化任务的间隔时间。
        lastTimeStamp = block.timestamp;  // 记录合约部署时的时间戳作为最后执行时间戳。
        counter = 0;

        owner = msg.sender;
        threshold = 0.001 ether;
    }
//    receive() external payable {}

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function getTotalDeposits() external view returns (uint256) {
        return totalDeposits;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if (totalDeposits > threshold) {
            lastTimeStamp = block.timestamp;  // 更新最后执行的时间戳。
            counter = counter + 1;  // 递增计数器。

            uint256 transferAmount = totalDeposits / 2;

            payable(owner).transfer(transferAmount);
            totalDeposits -= transferAmount;

            emit AutomatedTransfer(owner, transferAmount);
        }
    }
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance); // 转账给调用者
    }

}
