// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply); // 给合约创建者铸造初始供应量
    }
}

contract ContractFactory {
    // 1. 使用 create 部署 ERC20 代币合约
    function createContract(uint256 initialSupply) public returns (address) {
        MyToken token = new MyToken(initialSupply);
        return address(token);
    }

    // 2. 使用 create2 部署 ERC20 代币合约
    function createContract2(uint256 initialSupply, bytes32 salt) public returns (address) {
        bytes memory bytecode = type(MyToken).creationCode; // 获取合约字节码
        bytes memory bytecodeWithArgs = abi.encodePacked(bytecode, abi.encode(initialSupply));

        address tokenAddress;
        assembly {
            tokenAddress := create2(0, add(bytecodeWithArgs, 0x20), mload(bytecodeWithArgs), salt)
        }
        require(tokenAddress != address(0), "Contract deployment failed");
        return tokenAddress;
    }
}
