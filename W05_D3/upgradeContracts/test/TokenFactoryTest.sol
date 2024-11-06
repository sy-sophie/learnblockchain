// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenFactory.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract TokenFactoryUpgradeableTest is Test {
    MyERC20Upgradeable public tokenImplementation;
    TokenFactoryUpgradeable public factoryV1;
    TokenFactoryUpgradeableV2 public factoryV2;
    address public owner;
    address public user;


    uint256 public tokenPrice = 0.01 ether; // 设定每个 token 的价格
    uint256 public totalSupply = 100000;
    uint256 public perMint = 1000;

    function setUp() public {
        owner = vm.addr(1); // 测试账户1
        user = vm.addr(2);  // 测试账户2
        vm.startPrank(owner); // 模拟 owner 调用

        // 部署 MyERC20Upgradeable 实现合约
        tokenImplementation = new MyERC20Upgradeable();
        tokenImplementation.initialize("Token", totalSupply, perMint);

        // 部署第一个版本的工厂合约 (使用 new 部署)
        factoryV1 = new TokenFactoryUpgradeable();

        // 部署第二个版本的工厂合约 (支持代理并收取费用)
        factoryV2 = new TokenFactoryUpgradeableV2();
        factoryV2.initialize(address(tokenImplementation)); // 将实现合约地址传递给工厂合约
        vm.stopPrank();
    }

    function testDeployAndMintV1() public {
        vm.startPrank(owner); // 模拟 owner 调用
        // 使用 V1 工厂合约部署新的 ERC20 Token
        address newTokenAddr = factoryV1.deployInscription("TestTokenV1", totalSupply, 100);

        // 类型转换
        MyERC20Upgradeable newToken = MyERC20Upgradeable(newTokenAddr);

        // 验证新部署的 Token 的属性
        assertEq(newToken.symbol(), "TestTokenV1");
        assertEq(newToken.totalSupply(), 100); // 初始发行量为 1000
        vm.stopPrank();

        vm.startPrank(user);
        factoryV1.mintInscription(newTokenAddr);

        // 验证铸造的 Token 数量
        assertEq(newToken.balanceOf(user), 100);
        vm.stopPrank();
    }
    function testDeployAndMintV2() public {
        vm.startPrank(owner); // 模拟 owner 调用
        // 使用 V2 工厂合约部署带价格的 ERC20 Token
        address newTokenAddr = factoryV2.deployInscription("TestTokenV2", totalSupply, 200, tokenPrice);

        // 实例化新的 ERC20 Token
        MyERC20Upgradeable newToken = MyERC20Upgradeable(newTokenAddr);

        // 验证新部署的 Token 的属性
        assertEq(newToken.symbol(), "TestTokenV2");
        assertEq(newToken.totalSupply(), 200); // 初始发行量为 0
        vm.stopPrank();

        vm.startPrank(user);
        vm.deal(user, 1 ether); // 给用户一定的 ether 用于支付 mint 费用
        factoryV2.mintInscription{value: tokenPrice}(newTokenAddr);

        // 验证铸造的 Token 数量
        assertEq(newToken.balanceOf(user), 200);

        // 验证费用已经转给工厂合约的拥有者
        assertEq(address(owner).balance, tokenPrice); // 工厂合约的拥有者应该收到了支付的费用

    }
    function testUpgrade() public {
        // 部署新的实现合约 MyERC20UpgradeableV2
        MyERC20Upgradeable newImplementation = new MyERC20Upgradeable();

        // 模拟升级流程
        factoryV2.upgradeImplementation(address(newImplementation));

        // 确保升级后的实现生效
        assertEq(factoryV2.implementation(), address(newImplementation));

        // 验证升级前的行为 (部署和铸造 Token)
        address tokenAddrV1 = factoryV2.deployInscription("TestTokenBeforeUpgrade", totalSupply, 200, tokenPrice);
        MyERC20Upgradeable tokenV1 = MyERC20Upgradeable(tokenAddrV1);
        assertEq(tokenV1.symbol(), "TestTokenBeforeUpgrade");
        assertEq(tokenV1.totalSupply(), 200);


        // 使用 V2 工厂继续部署新的 ERC20 Token (升级后)
        address tokenAddrV2 = factoryV2.deployInscription("TestTokenAfterUpgrade", totalSupply, 300, tokenPrice);
        MyERC20Upgradeable tokenV2 = MyERC20Upgradeable(tokenAddrV2);
        assertEq(tokenV2.symbol(), "TestTokenAfterUpgrade");
        assertEq(tokenV2.totalSupply(), 300);

        // 验证升级后的 token 铸造是否正常
        vm.startPrank(user);
        vm.deal(user, 1 ether); // 给用户一定的 ether 用于支付 mint 费用
        factoryV2.mintInscription{value: tokenPrice}(tokenAddrV2);

        // 验证铸造的 Token 数量
        assertEq(tokenV2.balanceOf(user), 300);

        // 验证费用已经转给工厂合约的拥有者
        assertEq(address(owner).balance, tokenPrice); // 工厂合约的拥有者应该收到了支付的费用

        vm.stopPrank();
    }
}
