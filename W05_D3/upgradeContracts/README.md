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
### 合约地址

https://sepolia.etherscan.io/address/0xcbdb6fda9cbd89e07c87c4be456c96aa3aee392b

https://sepolia.etherscan.io/address/0x65260d424b011d942dfdda229ab36809e378dff4


### 测试结果

```json
Ran 3 tests for test/TokenFactoryTest.sol:TokenFactoryUpgradeableTest
[PASS] testDeployAndMintV1() (gas: 1046126)
Traces:
  [1046126] TokenFactoryUpgradeableTest::testDeployAndMintV1()
    ├─ [0] VM::startPrank(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    │   └─ ← [Return] 
    ├─ [998251] TokenFactoryUpgradeable::deployInscription("TestTokenV1", 100000 [1e5], 100)
    │   ├─ [778212] → new MyERC20Upgradeable@0xc8624589Ede8b4895513755817933fa17e3eF1F3
    │   │   └─ ← [Return] 3887 bytes of code
    │   ├─ [138392] MyERC20Upgradeable::initialize("TestTokenV1", 100000 [1e5], 100)
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: TokenFactoryUpgradeable: [0x2946259E0334f33A064106302415aD3391BeD384])
    │   │   ├─ emit Initialized(version: 1)
    │   │   └─ ← [Stop] 
    │   ├─ [47130] MyERC20Upgradeable::mint(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, value: 100)
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] MyERC20Upgradeable: [0xc8624589Ede8b4895513755817933fa17e3eF1F3]
    ├─ [1238] MyERC20Upgradeable::symbol() [staticcall]
    │   └─ ← [Return] "TestTokenV1"
    ├─ [0] VM::assertEq("TestTokenV1", "TestTokenV1") [staticcall]
    │   └─ ← [Return] 
    ├─ [382] MyERC20Upgradeable::totalSupply() [staticcall]
    │   └─ ← [Return] 100
    ├─ [0] VM::assertEq(100, 100) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    ├─ [0] VM::startPrank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF)
    │   └─ ← [Return] 
    ├─ [25853] TokenFactoryUpgradeable::mintInscription(MyERC20Upgradeable: [0xc8624589Ede8b4895513755817933fa17e3eF1F3])
    │   ├─ [25230] MyERC20Upgradeable::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF)
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 100)
    │   │   └─ ← [Stop] 
    │   └─ ← [Stop] 
    ├─ [615] MyERC20Upgradeable::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   └─ ← [Return] 100
    ├─ [0] VM::assertEq(100, 100) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    └─ ← [Stop] 

[PASS] testDeployAndMintV2() (gas: 325815)
Traces:
  [325815] TokenFactoryUpgradeableTest::testDeployAndMintV2()
    ├─ [0] VM::startPrank(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    │   └─ ← [Return] 
    ├─ [255657] TokenFactoryUpgradeableV2::deployInscription("TestTokenV2", 100000 [1e5], 200, 10000000000000000 [1e16])
    │   ├─ [9031] → new <unknown>@0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB
    │   │   └─ ← [Return] 45 bytes of code
    │   ├─ [141085] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::initialize("TestTokenV2", 100000 [1e5], 200)
    │   │   ├─ [138392] MyERC20Upgradeable::initialize("TestTokenV2", 100000 [1e5], 200) [delegatecall]
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: TokenFactoryUpgradeableV2: [0xDe09E74d4888Bc4e65F589e8c13Bce9F71DdF4c7])
    │   │   │   ├─ emit Initialized(version: 1)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   ├─ [47299] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::mint(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    │   │   ├─ [47130] MyERC20Upgradeable::mint(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) [delegatecall]
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, value: 200)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   └─ ← [Return] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB
    ├─ [1416] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::symbol() [staticcall]
    │   ├─ [1238] MyERC20Upgradeable::symbol() [delegatecall]
    │   │   └─ ← [Return] "TestTokenV2"
    │   └─ ← [Return] "TestTokenV2"
    ├─ [0] VM::assertEq("TestTokenV2", "TestTokenV2") [staticcall]
    │   └─ ← [Return] 
    ├─ [548] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::totalSupply() [staticcall]
    │   ├─ [382] MyERC20Upgradeable::totalSupply() [delegatecall]
    │   │   └─ ← [Return] 200
    │   └─ ← [Return] 200
    ├─ [0] VM::assertEq(200, 200) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    ├─ [0] VM::startPrank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF)
    │   └─ ← [Return] 
    ├─ [0] VM::deal(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000 [1e18])
    │   └─ ← [Return] 
    ├─ [37841] TokenFactoryUpgradeableV2::mintInscription{value: 10000000000000000}(0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB)
    │   ├─ [0] 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf::fallback{value: 10000000000000000}()
    │   │   └─ ← [Stop] 
    │   ├─ [25399] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF)
    │   │   ├─ [25230] MyERC20Upgradeable::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [delegatecall]
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 200)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   └─ ← [Stop] 
    ├─ [787] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   ├─ [615] MyERC20Upgradeable::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [delegatecall]
    │   │   └─ ← [Return] 200
    │   └─ ← [Return] 200
    ├─ [0] VM::assertEq(200, 200) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(10000000000000000 [1e16], 10000000000000000 [1e16]) [staticcall]
    │   └─ ← [Return] 
    └─ ← [Stop] 

[PASS] testUpgrade() (gas: 1395489)
Traces:
  [1395489] TokenFactoryUpgradeableTest::testUpgrade()
    ├─ [778212] → new MyERC20Upgradeable@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   └─ ← [Return] 3887 bytes of code
    ├─ [5324] TokenFactoryUpgradeableV2::upgradeImplementation(MyERC20Upgradeable: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   └─ ← [Stop] 
    ├─ [404] TokenFactoryUpgradeableV2::implementation() [staticcall]
    │   └─ ← [Return] MyERC20Upgradeable: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    ├─ [0] VM::assertEq(MyERC20Upgradeable: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], MyERC20Upgradeable: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]) [staticcall]
    │   └─ ← [Return] 
    ├─ [251157] TokenFactoryUpgradeableV2::deployInscription("TestTokenBeforeUpgrade", 100000 [1e5], 200, 10000000000000000 [1e16])
    │   ├─ [9031] → new <unknown>@0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB
    │   │   └─ ← [Return] 45 bytes of code
    │   ├─ [138585] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::initialize("TestTokenBeforeUpgrade", 100000 [1e5], 200)
    │   │   ├─ [138392] MyERC20Upgradeable::initialize("TestTokenBeforeUpgrade", 100000 [1e5], 200) [delegatecall]
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: TokenFactoryUpgradeableV2: [0xDe09E74d4888Bc4e65F589e8c13Bce9F71DdF4c7])
    │   │   │   ├─ emit Initialized(version: 1)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   ├─ [47299] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::mint(TokenFactoryUpgradeableTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   │   ├─ [47130] MyERC20Upgradeable::mint(TokenFactoryUpgradeableTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [delegatecall]
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: TokenFactoryUpgradeableTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], value: 200)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   └─ ← [Return] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB
    ├─ [1416] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::symbol() [staticcall]
    │   ├─ [1238] MyERC20Upgradeable::symbol() [delegatecall]
    │   │   └─ ← [Return] "TestTokenBeforeUpgrade"
    │   └─ ← [Return] "TestTokenBeforeUpgrade"
    ├─ [0] VM::assertEq("TestTokenBeforeUpgrade", "TestTokenBeforeUpgrade") [staticcall]
    │   └─ ← [Return] 
    ├─ [548] 0xB9235F7e3611C23c00263677A6Ce3EBf2b4109dB::totalSupply() [staticcall]
    │   ├─ [382] MyERC20Upgradeable::totalSupply() [delegatecall]
    │   │   └─ ← [Return] 200
    │   └─ ← [Return] 200
    ├─ [0] VM::assertEq(200, 200) [staticcall]
    │   └─ ← [Return] 
    ├─ [251157] TokenFactoryUpgradeableV2::deployInscription("TestTokenAfterUpgrade", 100000 [1e5], 300, 10000000000000000 [1e16])
    │   ├─ [9031] → new <unknown>@0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40
    │   │   └─ ← [Return] 45 bytes of code
    │   ├─ [138585] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40::initialize("TestTokenAfterUpgrade", 100000 [1e5], 300)
    │   │   ├─ [138392] MyERC20Upgradeable::initialize("TestTokenAfterUpgrade", 100000 [1e5], 300) [delegatecall]
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: TokenFactoryUpgradeableV2: [0xDe09E74d4888Bc4e65F589e8c13Bce9F71DdF4c7])
    │   │   │   ├─ emit Initialized(version: 1)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   ├─ [47299] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40::mint(TokenFactoryUpgradeableTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   │   ├─ [47130] MyERC20Upgradeable::mint(TokenFactoryUpgradeableTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [delegatecall]
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: TokenFactoryUpgradeableTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], value: 300)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   └─ ← [Return] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40
    ├─ [1416] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40::symbol() [staticcall]
    │   ├─ [1238] MyERC20Upgradeable::symbol() [delegatecall]
    │   │   └─ ← [Return] "TestTokenAfterUpgrade"
    │   └─ ← [Return] "TestTokenAfterUpgrade"
    ├─ [0] VM::assertEq("TestTokenAfterUpgrade", "TestTokenAfterUpgrade") [staticcall]
    │   └─ ← [Return] 
    ├─ [548] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40::totalSupply() [staticcall]
    │   ├─ [382] MyERC20Upgradeable::totalSupply() [delegatecall]
    │   │   └─ ← [Return] 300
    │   └─ ← [Return] 300
    ├─ [0] VM::assertEq(300, 300) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::startPrank(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF)
    │   └─ ← [Return] 
    ├─ [0] VM::deal(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, 1000000000000000000 [1e18])
    │   └─ ← [Return] 
    ├─ [37841] TokenFactoryUpgradeableV2::mintInscription{value: 10000000000000000}(0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40)
    │   ├─ [0] 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf::fallback{value: 10000000000000000}()
    │   │   └─ ← [Stop] 
    │   ├─ [25399] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF)
    │   │   ├─ [25230] MyERC20Upgradeable::mint(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [delegatecall]
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF, value: 300)
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Return] 
    │   └─ ← [Stop] 
    ├─ [787] 0x5a75b0f2a1547F6C00bd795f81FbFcE9200CAa40::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [staticcall]
    │   ├─ [615] MyERC20Upgradeable::balanceOf(0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF) [delegatecall]
    │   │   └─ ← [Return] 300
    │   └─ ← [Return] 300
    ├─ [0] VM::assertEq(300, 300) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(10000000000000000 [1e16], 10000000000000000 [1e16]) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return] 
    └─ ← [Stop] 

Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 935.50µs (487.92µs CPU time)

```
