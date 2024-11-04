// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StakePool.sol";
import "../src/RNT_token.sol";
import "../src/esRNT_token.sol";

contract StakePoolTest is Test {
    RNToken public rntToken;
    ESRNToken public esrntToken;
    StakePool public stakePool;

    address public user1 = vm.addr(1);

    function setUp() public {
        rntToken = new RNToken();
        esrntToken = new ESRNToken(rntToken);

        stakePool = new StakePool(address(rntToken), address(esrntToken));

        rntToken.transfer(user1, 1000); // 将一些 RNT 分配给用户
    }

    function stakeProcess() public {
        // 1. StakePool.stake 质押 10 RNT
        //    验证 是否 记账 stakes
        vm.startPrank(user1);
        rntToken.approve(address(stakePool), 10); // 授权给 stakePool
        stakePool.stake(10);
        vm.stopPrank();
        (uint256 stakedAmount, ,) = stakePool.stakes(user1);
        assertEq(stakedAmount, 10);

        // 2. 条件：1天 后 10个RNT 产生 10 esRNT，
        //    StakePool.claim 开始计算 奖励，触发 ESRNToken.mint()
        //    验证 是否 记账 locks[]
        //    验证 用户 是否 收到 10 esRNT
        vm.startPrank(user1);
        vm.warp(block.timestamp + 1 days);  // 将当前时间提前 1 天
        stakePool.claim();

        (, uint256 lockAmount,) = esrntToken.locks(0);
        assertEq(lockAmount, 10 ether); // Check that 10 esRNT was locked

        uint256 user1Balance = esrntToken.balanceOf(user1);
        assertEq(user1Balance, 10 ether); // Balance should be 10 esRNT after claim

        // 3. ESRNToken.burn，领取 的是 RNT
        //    验证 用户领取奖励 amount 是否正确
        vm.startPrank(user1);
        uint256 initialRNTBalance = rntToken.balanceOf(user1);
        esrntToken.burn(0);

        uint256 unlocked = (lockAmount * (block.timestamp - (block.timestamp - 1 days))) / 30 days; // Should be 0 for the first burn since no time has passed since claiming
        uint256 expectedRNT = unlocked; // User should receive unlocked amount of RNT

        uint256 finalRNTBalance = rntToken.balanceOf(user1);
        assertEq(finalRNTBalance, initialRNTBalance + expectedRNT, "RNT balance after burn should match expected amount");

        uint256 esRNTBalanceAfterBurn = esrntToken.balanceOf(user1);
        assertEq(esRNTBalanceAfterBurn, 0, "User's esRNT balance should be 0 after burning all");
    }
}
