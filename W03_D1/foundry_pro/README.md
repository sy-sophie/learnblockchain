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

### 作业笔记

合约：`Bank.sol`，部署脚本`BankScript.sol`

```sh  
# ETHERSCAN_API_KEY 在以太坊主网获得

# 部署脚本
forge script ./script/BankScript.sol -s "run()" --account privateS4_02 --rpc-url https://ethereum-sepolia-rpc.publicnode.com  --broadcast --verify -vvvv

# safe：sep:0x318E1cACDff7DD3414d17d23201b635f486a0F69

# 部署地址：0xBD572FE2928A9eA79c0c029c97dfe73017ca6Ab2
```

[sepolia-0x8690cb51d083e3818894e2465f573964bace2961](https://sepolia.etherscan.io/address/0x8690cb51d083e3818894e2465f573964bace2961)

