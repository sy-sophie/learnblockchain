// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MultiSign} from "../src/MultiSign.sol";

contract MultiSignTest is Test {
    MultiSign multiSign;
    address payable owner1 = payable(address(0x1)); // 多签钱包 持有人
    address payable owner2 = payable(address(0x2)); // 多签钱包 持有人
    address payable owner3 = payable(address(0x3)); // 多签钱包 持有人
    address payable recipient = payable(address(0x4));

    function setUp() public {
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;
        multiSign = new MultiSign(owners, 2); // 需要 2 个批准
    }

    function testSubmitProposal() public {
        multiSign.submitProposal(recipient, 100 ether);

        // 检查提案是否创建
        (address payable propRecipient, uint256 amount, , ,) = multiSign.proposals(0);
        assertEq(propRecipient, recipient);
        assertEq(amount, 100 ether);
    }

    function testApproveProposal() public {
        multiSign.submitProposal(recipient, 100 ether);
        multiSign.approveProposal(0); // owner1 批准提案
        multiSign.approveProposal(0); // owner2 批准提案

        // 检查提案批准计数
        ( , , uint256 approvalCount, ,) = multiSign.proposals(0);
        assertEq(approvalCount, 2);
    }

    function testExecuteProposal() public {
        multiSign.submitProposal(recipient, 100 ether);
        multiSign.approveProposal(0); // owner1 批准提案
        multiSign.approveProposal(0); // owner2 批准提案

        // 模拟接收以太币
        vm.deal(address(multiSign), 100 ether);

        // 执行提案
        multiSign.approveProposal(0);

        // 检查接收者的余额
        assertEq(recipient.balance, 100 ether);
    }

    function testFailApproveProposalAsNonOwner() public {
        address nonOwner = address(0x5);
        vm.startPrank(nonOwner);

        // 确保非持有人不能批准提案
        vm.expectRevert("Not an owner");
        multiSign.approveProposal(0);

        vm.stopPrank();
    }

    function testFailExecuteProposalWithoutEnoughApprovals() public {
        multiSign.submitProposal(recipient, 100 ether);
        multiSign.approveProposal(0); // 只有 owner1 批准

        // 尝试执行提案，应该失败
        vm.expectRevert("Not enough approvals");
        multiSign.executeProposal(0);
    }
}
