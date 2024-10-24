## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Homework

### 资料链接

[eip-20](https://eips.ethereum.org/EIPS/eip-20)   
[eip-721](https://eips.ethereum.org/EIPS/eip-721)   

[eip-191](https://eips.ethereum.org/EIPS/eip-191)   
[eip-712](https://eips.ethereum.org/EIPS/eip-712)   
[eip-2612](https://eips.ethereum.org/EIPS/eip-2612)


[github-oz-ERC20Permit](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Permit.sol)    
[github-oz-ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)

### ERC20Permit源码解读

```solidity
 function permit(
        address owner,   // 令牌所有者的地址
        address spender, // 被授权支出的地址
        uint256 value,   // 允许支出的令牌数量
        uint256 deadline,// 签名的有效截止时间
        uint8 v,         
        bytes32 r,
        bytes32 s        // ECDSA 签名的组件
    ) public virtual {
        if (block.timestamp > deadline) { // 检查当前时间是否超过 deadline
            revert ERC2612ExpiredSignature(deadline);
        }
        // 使用 keccak256 哈希函数计算结构体的哈希值。abi.encode 函数将传入的参数编码为二进制格式 
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        // 从签名中恢复出签名者的地址。这个地址应该与 owner 匹配
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }
```
