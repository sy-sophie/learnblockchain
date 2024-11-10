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

# 测试结果

```json
Ran 1 test for test/BankLinkedStorageTest.sol:BankLinkedStorageTest
[PASS] testGetTopUsers() (gas: 681207)
Traces:
  [1142058] BankLinkedStorageTest::setUp()
    ├─ [1103581] → new BankLinkedStorage@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   └─ ← [Return] 5291 bytes of code
    └─ ← [Stop] 

  [681207] BankLinkedStorageTest::testGetTopUsers()
    ├─ [0] VM::deal(ECRecover: [0x0000000000000000000000000000000000000001], 1000000000000000000 [1e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(SHA-256: [0x0000000000000000000000000000000000000002], 2000000000000000000 [2e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(RIPEMD-160: [0x0000000000000000000000000000000000000003], 3000000000000000000 [3e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(Identity: [0x0000000000000000000000000000000000000004], 4000000000000000000 [4e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(ModExp: [0x0000000000000000000000000000000000000005], 5000000000000000000 [5e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(ECAdd: [0x0000000000000000000000000000000000000006], 6000000000000000000 [6e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(ECMul: [0x0000000000000000000000000000000000000007], 7000000000000000000 [7e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(ECPairing: [0x0000000000000000000000000000000000000008], 8000000000000000000 [8e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(Blake2F: [0x0000000000000000000000000000000000000009], 9000000000000000000 [9e18])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(PointEvaluation: [0x000000000000000000000000000000000000000A], 10000000000000000000 [1e19])
    │   └─ ← [Return] 
    ├─ [0] VM::deal(0x000000000000000000000000000000000000000b, 11000000000000000000 [1.1e19])
    │   └─ ← [Return] 
    ├─ [0] VM::prank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return] 
    ├─ [71393] BankLinkedStorage::deposit{value: 1000000000000000000}()
    │   ├─ emit Deposit(user: ECRecover: [0x0000000000000000000000000000000000000001], amount: 1000000000000000000 [1e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(SHA-256: [0x0000000000000000000000000000000000000002])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 2000000000000000000}()
    │   ├─ emit Deposit(user: SHA-256: [0x0000000000000000000000000000000000000002], amount: 2000000000000000000 [2e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(RIPEMD-160: [0x0000000000000000000000000000000000000003])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 3000000000000000000}()
    │   ├─ emit Deposit(user: RIPEMD-160: [0x0000000000000000000000000000000000000003], amount: 3000000000000000000 [3e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(Identity: [0x0000000000000000000000000000000000000004])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 4000000000000000000}()
    │   ├─ emit Deposit(user: Identity: [0x0000000000000000000000000000000000000004], amount: 4000000000000000000 [4e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(ModExp: [0x0000000000000000000000000000000000000005])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 5000000000000000000}()
    │   ├─ emit Deposit(user: ModExp: [0x0000000000000000000000000000000000000005], amount: 5000000000000000000 [5e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(ECAdd: [0x0000000000000000000000000000000000000006])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 6000000000000000000}()
    │   ├─ emit Deposit(user: ECAdd: [0x0000000000000000000000000000000000000006], amount: 6000000000000000000 [6e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(ECMul: [0x0000000000000000000000000000000000000007])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 7000000000000000000}()
    │   ├─ emit Deposit(user: ECMul: [0x0000000000000000000000000000000000000007], amount: 7000000000000000000 [7e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(ECPairing: [0x0000000000000000000000000000000000000008])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 8000000000000000000}()
    │   ├─ emit Deposit(user: ECPairing: [0x0000000000000000000000000000000000000008], amount: 8000000000000000000 [8e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(Blake2F: [0x0000000000000000000000000000000000000009])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 9000000000000000000}()
    │   ├─ emit Deposit(user: Blake2F: [0x0000000000000000000000000000000000000009], amount: 9000000000000000000 [9e18])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(PointEvaluation: [0x000000000000000000000000000000000000000A])
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 10000000000000000000}()
    │   ├─ emit Deposit(user: PointEvaluation: [0x000000000000000000000000000000000000000A], amount: 10000000000000000000 [1e19])
    │   └─ ← [Stop] 
    ├─ [0] VM::prank(0x000000000000000000000000000000000000000b)
    │   └─ ← [Return] 
    ├─ [47869] BankLinkedStorage::deposit{value: 11000000000000000000}()
    │   ├─ emit Deposit(user: 0x000000000000000000000000000000000000000b, amount: 11000000000000000000 [1.1e19])
    │   └─ ← [Stop] 
    ├─ [6341] BankLinkedStorage::getTopUsers() [staticcall]
    │   └─ ← [Return] [0x000000000000000000000000000000000000000b, 0x000000000000000000000000000000000000000A, 0x0000000000000000000000000000000000000009, 0x0000000000000000000000000000000000000008, 0x0000000000000000000000000000000000000007, 0x0000000000000000000000000000000000000006, 0x0000000000000000000000000000000000000005, 0x0000000000000000000000000000000000000004, 0x0000000000000000000000000000000000000003, 0x0000000000000000000000000000000000000002]
    ├─ [0] VM::assertEq(0x000000000000000000000000000000000000000b, 0x000000000000000000000000000000000000000b) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(PointEvaluation: [0x000000000000000000000000000000000000000A], PointEvaluation: [0x000000000000000000000000000000000000000A]) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(Blake2F: [0x0000000000000000000000000000000000000009], Blake2F: [0x0000000000000000000000000000000000000009]) [staticcall]
    │   └─ ← [Return] 
    └─ ← [Stop] 

```
