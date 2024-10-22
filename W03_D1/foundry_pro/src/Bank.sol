// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;


contract Bank {
    address public owner;

    mapping(address => uint) public balances; // 用户地址 => 金额

    struct TopUser {
        address user;
        uint balance;
    }
    TopUser[3] public topUsers; // 存储 前3名 用户地址

    constructor() {
        owner = msg.sender; // 将部署者设为管理员
    }

    modifier onlyAdmin {
        require(msg.sender == owner, "only admin can be operate");
        _;
    }

    function setAdmin(address addr) public onlyAdmin {
        require(addr != address(0), "address can not be 0");
        owner = addr;
    }


    receive() external payable {
        require(msg.value > 0, "You need to deposit some ether.");
        balances[msg.sender] += msg.value;
        updateTopThreeBalances(msg.sender);
    }


    function updateTopThreeBalances(address _user) internal  {
        uint currentUserBalance = balances[_user];

        for (uint i =0; i< 3; i++) {
            if (currentUserBalance > topUsers[i].balance){
                // 将当前用户的余额插入到前三名，并将其他余额后移
                for(uint j = 2; j > i; j--){
                    topUsers[j] = topUsers[j - 1];
                }
                topUsers[i] = TopUser(_user, currentUserBalance);
                break;
            }
        }
    }

    function withdraw() external returns (uint) {
        require(msg.sender == owner, 'not owner');
        uint totalBalance = address(this).balance;
        (bool success,) = payable(owner).call{value: totalBalance}("");
        require(success, "Transfer failed.");
        return totalBalance;
    }
}
