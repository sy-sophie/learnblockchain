// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

//实现⼀个简单的多签合约钱包，合约包含的功能：
//
//  创建多签钱包时，确定所有的多签持有⼈和签名门槛
//  多签持有⼈可提交提案
//  其他多签⼈确认提案（使⽤交易的⽅式确认即可）
//  达到多签⻔槛、任何⼈都可以执⾏交易

contract MultiSign {
// 定义提案的结构体
    struct Proposal {
        address payable recipient; // 提案的接收者地址
        uint256 amount; // 提案中转账的金额
        uint256 approvalCount; // 获得的批准数量
        mapping(address => bool) approvals; // 存储各个持有人的批准状态
        bool executed; // 提案是否已被执行的标志
    }

    address[] public owners; // 存储多签持有人的地址数组
    uint256 public required; // 所需的批准数量门槛

    Proposal[] public proposals; // 存储所有提案的数组

    // 用于记录事件的日志
    event ProposalCreated(uint256 proposalId, address indexed recipient, uint256 amount); // 提案创建时触发
    event ProposalApproved(uint256 proposalId, address indexed owner); // 提案获得批准时触发
    event ProposalExecuted(uint256 proposalId, address indexed recipient, uint256 amount); // 提案执行时触发

    // 构造函数，初始化合约时设置持有人和签名门槛
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Must have at least one owner"); // 确保至少有一个持有人
        require(_required > 0 && _required <= _owners.length, "Invalid required number of approvals"); // 确保批准数量有效

        owners = _owners; // 设置持有人的地址
        required = _required; // 设置批准数量门槛
    }

    // 限制只有多签持有人可以调用的修饰符
    modifier onlyOwners() {
        bool isOwner = false; // 初始化标志位，判断调用者是否为持有人
        for (uint256 i = 0; i < owners.length; i++) { // 遍历所有持有人
            if (msg.sender == owners[i]) { // 如果当前调用者是持有人
                isOwner = true; // 设置标志位为 true
                break; // 结束循环
            }
        }
        require(isOwner, "Not an owner"); // 如果不是持有人，抛出异常
        _; // 继续执行函数体
    }

    // 提交提案函数
    function submitProposal(address payable _recipient, uint256 _amount) public onlyOwners {
        Proposal storage newProposal = proposals.push(); // 创建新的提案并推入提案数组
        newProposal.recipient = _recipient; // 设置提案接收者
        newProposal.amount = _amount; // 设置提案金额
        newProposal.approvalCount = 0; // 初始化批准计数为 0
        newProposal.executed = false; // 初始化提案未被执行

        emit ProposalCreated(proposals.length - 1, _recipient, _amount); // 触发提案创建事件
    }

    // 批准提案函数
    function approveProposal(uint256 _proposalId) public onlyOwners {
        Proposal storage proposal = proposals[_proposalId]; // 获取指定 ID 的提案
        require(!proposal.approvals[msg.sender], "Already approved this proposal"); // 确保当前持有人未批准该提案
        require(!proposal.executed, "Proposal already executed"); // 确保提案未被执行

        proposal.approvals[msg.sender] = true; // 标记当前持有人已批准该提案
        proposal.approvalCount++; // 增加批准计数

        emit ProposalApproved(_proposalId, msg.sender); // 触发提案批准事件

        // 检查是否达到了执行提案的批准数量
        if (proposal.approvalCount >= required) {
            executeProposal(_proposalId); // 达到门槛后执行提案
        }
    }

    // 执行提案的内部函数
    function executeProposal(uint256 _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId]; // 获取指定 ID 的提案
        require(!proposal.executed, "Proposal already executed"); // 确保提案未被执行
        require(proposal.approvalCount >= required, "Not enough approvals"); // 确保已获得足够的批准

        proposal.executed = true; // 标记提案已被执行
        proposal.recipient.transfer(proposal.amount); // 向提案接收者转账指定金额

        emit ProposalExecuted(_proposalId, proposal.recipient, proposal.amount); // 触发提案执行事件
    }

    // 允许合约接收以太币
    receive() external payable {} // 提供接收以太币的功能
}

// 1. 建立多签 account
//    name：second_test
//    networks: [sepolia]
// 2. 给 second_test 添加 signers = []
//    signe：name, EOA 地址
//    requires：1 <= requires <= signers.length
