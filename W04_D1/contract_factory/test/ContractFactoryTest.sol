// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ContractFactory.sol";

contract ContractFactoryTest is Test {
    ContractFactory factory;
    address implementation; // 存储实现合约地址

    function setUp() public {
        factory = new ContractFactory();
        implementation = address(new C()); // 部署实现合约
    }

    function testCreateContract1() public {
        address newContract = factory.createContract1();
        C createdContract = C(newContract);
        assertEq(createdContract.value(), 42); // 检查 value 是否为 42
    }

    function testCreateContract2() public { // TODO ???
        address newClone = factory.createContract2(implementation);
        C createdClone = C(newClone);
        assertEq(createdClone.value(), 42); // 检查克隆合约的 value
    }

    function testCreateContract3() public {
        uint256 salt = 1; // 示例盐值
        address newContract = factory.createContract3(salt);
        C createdContract = C(newContract);
        assertEq(createdContract.value(), 42); // 检查 value 是否为 42
    }

    function testCreateContract4() public {
        bytes32 salt = keccak256(abi.encodePacked(uint256(1))); // 示例盐值
        address newContract = factory.createContract4(salt, 42);
        C createdContract = C(newContract);
        assertEq(createdContract.value(), 42); // 检查 value 是否为 42
    }
}
