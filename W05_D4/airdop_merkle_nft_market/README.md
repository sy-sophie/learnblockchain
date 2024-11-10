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
[PASS] test_Airdrop() (gas: 358968)
Traces:
[398768] AirdopMerkleNFTMarketTest::test_Airdrop()
├─ [0] VM::startPrank(0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b)
│   └─ ← [Return]
├─ [191083] AirdopMerkleNFTMarket::mintNFTThroughMarket(0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, "https://example.com/metadata.json", 60)
│   ├─ [140304] NcNFT::mintNFT(0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, "https://example.com/metadata.json")
│   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, tokenId: 0)
│   │   ├─ emit MetadataUpdate(_tokenId: 0)
│   │   └─ ← [Return] 0
│   └─ ← [Return] 0
├─ [552] NcNFT::ownerOf(0) [staticcall]
│   └─ ← [Return] 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b
├─ [0] VM::assertEq(0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b) [staticcall]
│   └─ ← [Return]
├─ [24767] NcNFT::approve(AirdopMerkleNFTMarket: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], 0)
│   ├─ emit Approval(owner: 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, approved: AirdopMerkleNFTMarket: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], tokenId: 0)
│   └─ ← [Stop]
├─ [0] VM::stopPrank()
│   └─ ← [Return]
├─ [0] VM::startPrank(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9)
│   └─ ← [Return]
├─ [2629] NCToken::nonces(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9) [staticcall]
│   └─ ← [Return] 0
├─ [3216] SigUtils::getTypedDataHash(Permit({ owner: 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, spender: 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9, value: 60, nonce: 0, deadline: 86401 [8.64e4] })) [staticcall]
│   └─ ← [Return] 0xc672fb8e07a1cd5a62b3d4dfab5ab20aef71b268a78bc9ed419cbb7beceb8107
├─ [0] VM::sign("<pk>", 0xc672fb8e07a1cd5a62b3d4dfab5ab20aef71b268a78bc9ed419cbb7beceb8107) [staticcall]
│   └─ ← [Return] 27, 0xc2614b718f66a57a04ea0ce9a6b871cc17bd1b41250a2bffdf04af24385c3b35, 0x123bae36b5eb6c4ea7a5c88880ea21d3358e09193d9f07a2286e78e5a41bad09
├─ [0] VM::stopPrank()
│   └─ ← [Return]
├─ [129963] AirdopMerkleNFTMarket::multicall([0xa9dcc5f100000000000000000000000036ce3e9d03e4b8ab33d1d6a3533f67143ebb364b000000000000000000000000000000000000000000000000000000000000003c0000000000000000000000001611d79981b8f25ae979e2f34b05b1acf56e8ac900000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000015181000000000000000000000000000000000000000000000000000000000000000237d95e0aa71e34defa88b4c43498bc8b90207e31ad0ef4aa6f5bea78bd25a1ab4beda981c9d34f2dd099131be6049a1d87676d227e63f4a409ee629043314b4f0000000000000000000000000000000000000000000000000000000000000041c2614b718f66a57a04ea0ce9a6b871cc17bd1b41250a2bffdf04af24385c3b35123bae36b5eb6c4ea7a5c88880ea21d3358e09193d9f07a2286e78e5a41bad091b00000000000000000000000000000000000000000000000000000000000000, 0x35df64200000000000000000000000001611d79981b8f25ae979e2f34b05b1acf56e8ac9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000036ce3e9d03e4b8ab33d1d6a3533f67143ebb364b000000000000000000000000000000000000000000000000000000000000003c000000000000000000000000000000000000000000000000000000000000000237d95e0aa71e34defa88b4c43498bc8b90207e31ad0ef4aa6f5bea78bd25a1ab4beda981c9d34f2dd099131be6049a1d87676d227e63f4a409ee629043314b4f])
│   ├─ [57795] AirdopMerkleNFTMarket::permitPrePay(NFTOrder({ maker: 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, price: 60 }), 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, [0x37d95e0aa71e34defa88b4c43498bc8b90207e31ad0ef4aa6f5bea78bd25a1ab, 0x4beda981c9d34f2dd099131be6049a1d87676d227e63f4a409ee629043314b4f], 0xc2614b718f66a57a04ea0ce9a6b871cc17bd1b41250a2bffdf04af24385c3b35123bae36b5eb6c4ea7a5c88880ea21d3358e09193d9f07a2286e78e5a41bad091b, 86401 [8.64e4]) [delegatecall]
│   │   ├─ [49030] NCToken::permit(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, AirdopMerkleNFTMarket: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], 60, 86401 [8.64e4], 27, 0xc2614b718f66a57a04ea0ce9a6b871cc17bd1b41250a2bffdf04af24385c3b35, 0x123bae36b5eb6c4ea7a5c88880ea21d3358e09193d9f07a2286e78e5a41bad09)
│   │   │   ├─ [3000] PRECOMPILES::ecrecover(0xc672fb8e07a1cd5a62b3d4dfab5ab20aef71b268a78bc9ed419cbb7beceb8107, 27, 87920597482989049290220401534093788769183580304685481345706388209858730801973, 8247077630180553478183705947759537843408432646155047747863634235025484655881) [staticcall]
│   │   │   │   └─ ← [Return] 0x0000000000000000000000001611d79981b8f25ae979e2f34b05b1acf56e8ac9
│   │   │   ├─ emit Approval(owner: 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, spender: AirdopMerkleNFTMarket: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], value: 60)
│   │   │   └─ ← [Stop]
│   │   └─ ← [Stop]
│   ├─ [68640] AirdopMerkleNFTMarket::claimNFT(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, 0, [0x37d95e0aa71e34defa88b4c43498bc8b90207e31ad0ef4aa6f5bea78bd25a1ab, 0x4beda981c9d34f2dd099131be6049a1d87676d227e63f4a409ee629043314b4f], NFTOrder({ maker: 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, price: 60 })) [delegatecall]
│   │   ├─ [2585] NCToken::balanceOf(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9) [staticcall]
│   │   │   └─ ← [Return] 1000000000000000000000 [1e21]
│   │   ├─ [927] NCToken::allowance(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, AirdopMerkleNFTMarket: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9]) [staticcall]
│   │   │   └─ ← [Return] 60
│   │   ├─ [28245] NCToken::transferFrom(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, 30)
│   │   │   ├─ emit Transfer(from: 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, to: 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, value: 30)
│   │   │   └─ ← [Return] true
│   │   ├─ [31045] NcNFT::safeTransferFrom(0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, 0)
│   │   │   ├─ emit Transfer(from: 0x36cE3E9D03E4B8AB33D1d6A3533F67143eBb364b, to: 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, tokenId: 0)
│   │   │   └─ ← [Stop]
│   │   └─ ← [Stop]
│   └─ ← [Return] [0x, 0x]
├─ [552] NcNFT::ownerOf(0) [staticcall]
│   └─ ← [Return] 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9
├─ [0] VM::assertEq(0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9, 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9) [staticcall]
│   └─ ← [Return]
├─ [0] VM::stopPrank()
│   └─ ← [Return]
└─ ← [Return]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.10ms (489.54µs CPU time)

```
