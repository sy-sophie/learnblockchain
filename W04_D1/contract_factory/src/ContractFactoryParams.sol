// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
contract D {
    uint256 public value;
    constructor(uint256 _value) {
        value = _value;
    }
}

contract ContractFactoryParams {
    // 1. new（create）
    function createContract1(uint256 _value) public returns (address) {
        D d = new D(_value); // 传递参数给构造函数
        return address(d);
    }
    // 2. create2
    function createContractParams4(bytes32 salt, uint256 _value) public  returns (address){
        // 拼接合约字节码和参数
        bytes memory bytecode = abi.encodePacked(type(D).creationCode, abi.encode(_value));

        address contractAddress;
        assembly {
            contractAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        // 第一个参数是部署时发送的以太币数量（这里为 0）
        // 第二个参数是合约字节码的内存位置   add(bytecode, 0x20) == add(bytecode, 32)
        // 第三个参数是字节码的长度
        // 第四个参数是盐（salt），用于生成合约地址
        }
        require(contractAddress != address(0), "Contract deployment failed");
        return contractAddress;
    }
}
