```shell
type OrderBook @entity(immutable: true) { # 挂单（销售订单）
    id: Bytes!  #              订单的哈希（例如 orderId）生成
    nft: Bytes! # address      NFT 的合约地址
    tokenId: BigInt! # uint256
    seller: Bytes! # address   该挂单的用户
    payToken: Bytes! # address ERC20 代币的地址
    price: BigInt! # uint256
    deadline: BigInt! # uint256
    blockNumber: BigInt!
    blockTimestamp: BigInt!
    transactionHash: Bytes! #  创建该订单的交易哈希 以上 event List
    cancelTxHash: Bytes!
    filledTxHash: Bytes!
}
# event List：  更新 OrderBook基本信息
# event Cancel：更新 cancelTxHash
# event Sold：  更新 filledTxHash
type FilledOrder @entity(immutable: true) {
    id: Bytes!    # 
    buyer: Bytes! # address 购买者
    fee: BigInt! # uint256  手续费
    blockNumber: BigInt!   # 区块
    blockTimestamp: BigInt!
    transactionHash: Bytes! # relation  购买交易的哈希
    order: OrderBook        # 关联的 OrderBook 实体，表示已完成的订单详情
}
# event Sold： 
```

```sh 
# 配置 .env 文件
# ETHERSCAN_API_KEY=9UJG58E5CAF59EJDBQNZFWI2GWM9NQ9A7R

# 部署脚本
forge script ./script/NFTMarketScript.sol --sig "run()" --account privateS4 --rpc-url https://ethereum-sepolia-rpc.publicnode.com --broadcast --verify -vvvv

```

[MyToken (MTK)-sepolia-地址](https://sepolia.etherscan.io/address/0x6ac936d3fc93a2e7e7da040d68ad283fe7a03058#code)

[MyNFT-sepolia-地址](https://sepolia.etherscan.io/address/0xaa02ff97a9aa19a01aff013f171cb902429d509a)

[NFTMarket--sepolia-地址](https://sepolia.etherscan.io/address/0x1b09a18f27a8e5aa51431148261cd258d4142fc0#code)
