// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol"; // 引入 Foundry 的测试库
import "../src/ContractFactoryParams.sol"; // 引入你的合约

contract ContractFactoryParamsTest is Test {
    ContractFactoryParams factory;

    function setUp() public {
        factory = new ContractFactoryParams(); // 部署合约工厂
    }

    function testCreateContract1() public {
        uint256 valueToSet = 100; // 测试值
        address contractAddress = factory.createContract1(valueToSet); // 使用 createContract1 创建合约

        // 断言合约地址不为零
        assertNotEq(contractAddress, address(0), "Contract address should not be zero.");

        // 检查合约中的值
        D deployedContract = D(contractAddress);
        assertEq(deployedContract.value(), valueToSet, "The value should be set correctly.");
    }

    function testCreateContractParams4() public {
        uint256 valueToSet = 200; // 测试值
        bytes32 salt = keccak256(abi.encodePacked("testSalt")); // 生成盐

        address contractAddress = factory.createContractParams4(salt, valueToSet); // 使用 createContractParams4 创建合约

        // 断言合约地址不为零
        assertNotEq(contractAddress, address(0), "Contract address should not be zero.");

        // 检查合约中的值
        D deployedContract = D(contractAddress);
        assertEq(deployedContract.value(), valueToSet, "The value should be set correctly.");
    }
}
