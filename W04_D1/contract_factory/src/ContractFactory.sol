// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
//import "clone-factory/CloneFactory.sol";
contract C {
    uint256 public value;
    constructor() {
        value = 42; // 默认值
    }
}

contract ContractFactory{
    // 1. new（create）
    function createContract1() public returns (address) {
        C c = new C();
        return address(c);
    }
    // 2. 合约工厂库（proxy）
    function createContract2(address impl) public returns (address) {
        return createClone(impl);
    }
    // 3. create2
    function createContract3(uint _salt) public returns (address) {
        // 计算盐的哈希值
        bytes32 salt = keccak256(abi.encodePacked(_salt));
        C c = new C{salt: salt}();
        return address(c);
    }
    // 4. create2
    function createContract4(bytes32 salt, uint256 _value) public  returns (address){
        bytes memory bytecode = type(C).creationCode; // type(C).creationCode 获取合约的字节码
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

    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
        require(result != address(0), "Clone creation failed");
    }
}
