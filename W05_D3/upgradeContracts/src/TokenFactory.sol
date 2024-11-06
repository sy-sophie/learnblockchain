// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract MyERC20Upgradeable is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    uint public perMint;
    uint public totalSupplyToken;

    // 初始化函数，用于代替构造函数
    function initialize(string memory _symbol, uint _totalSupply, uint _perMint) public initializer {
        __ERC20_init("MyERC20TOKEN", _symbol);
        __Ownable_init(msg.sender);
        perMint = _perMint;
        totalSupplyToken = _totalSupply;
    }

    // mint功能
    function mint(address to) external onlyOwner {
        _mint(to, perMint);
    }

    // 设置每次mint的数量
    function setPerMint(uint _perMint) external onlyOwner {
        uint currentSupply = totalSupply();
        require(currentSupply + perMint <= totalSupplyToken, "Exceeds max total supply");
        perMint = _perMint;
    }
}
// 使用 new 关键字创建 ERC20 Token
contract TokenFactoryUpgradeable {
    // 第一个版本的deploy方法
    function deployInscription(string memory symbol, uint totalSupply, uint perMint) public returns (address) {
        MyERC20Upgradeable token = new MyERC20Upgradeable();  // 使用new方式部署ERC20 token
        token.initialize(symbol, totalSupply, perMint);  // 初始化token
        token.mint(msg.sender);  // 初始发行给工厂调用者
        return address(token);
    }

    // mint方法
    function mintInscription(address tokenAddr) public {
        MyERC20Upgradeable token = MyERC20Upgradeable(tokenAddr);
        token.mint(msg.sender);  // 每次调用mint时，mint perMint数量
    }
}
// 使用最小代理合约和收费机制
contract TokenFactoryUpgradeableV2 is Initializable, OwnableUpgradeable {
    address public implementation;
    mapping(address => uint) public tokenPrices;  // 用于存储每个token的价格

    function initialize(address _implementation) public initializer {  // 初始化工厂合约
        __Ownable_init(msg.sender);
        implementation = _implementation;
    }
    function upgradeImplementation(address _newImplementation) external { // 升级实现合约
        implementation = _newImplementation;
    }

    // 第二个版本的deploy方法，支持价格参数
    function deployInscription(string memory symbol, uint totalSupply, uint perMint, uint price) public returns (address) {
        address clone = Clones.clone(implementation);  // 创建最小代理合约
        MyERC20Upgradeable(clone).initialize(symbol, totalSupply, perMint);  // 初始化代理合约
        tokenPrices[clone] = price;  // 保存token价格

        MyERC20Upgradeable(clone).mint(msg.sender);  // 初始发行总量（可以根据需求调整）

        return clone;
    }

    // mint方法，收取费用
    function mintInscription(address tokenAddr) public payable {
        uint price = tokenPrices[tokenAddr];
        require(msg.value >= price, "Insufficient funds to mint tokens");

        // 支付的费用会被转给工厂合约的所有者
        payable(owner()).transfer(msg.value);

        MyERC20Upgradeable token = MyERC20Upgradeable(tokenAddr);
        token.mint(msg.sender);
    }
    // 允许提取工厂合约的资金
    function withdraw() external {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(msg.sender).transfer(balance);

    }
}
