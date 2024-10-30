import {
  Cancel as CancelEvent,
  List as ListEvent,
  Sold as SoldEvent
} from "../generated/NFTMarket/NFTMarket"
import {
  OrderBook,
  FilledOrder
} from "../generated/schema"
import {Bytes} from "@graphprotocol/graph-ts";

export function handleList(event: ListEvent): void {
  let entity = new OrderBook(
      event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nft = event.params.nft
  entity.tokenId = event.params.tokenId
  entity.seller = event.params.seller
  entity.payToken = event.params.payToken
  entity.price = event.params.price
  entity.deadline = event.params.deadline

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash
  entity.cancelTxHash = Bytes.fromHexString("0x00") // 使用合适的 Bytes 默认值
  entity.filledTxHash = Bytes.fromHexString("0x00")

  entity.save()
}
export function handleCancel(event: CancelEvent): void {
  // 更新 OrderBook 的 cancelTxHash
  let orderId = event.params.orderId // 查询对应的 OrderBook 实体
  let entity = OrderBook.load(orderId)

  if (entity) {
    // 更新 cancelTxHash
    entity.cancelTxHash = event.transaction.hash

    // 保存更新后的实体
    entity.save()
  }

}

export function handleSold(event: SoldEvent): void {
  let entity = new FilledOrder(
      event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.order = event.params.orderId
  entity.buyer = event.params.buyer
  entity.fee = event.params.fee

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash
  // 拿到 OrderBook 的 id 存到 entity.order
  entity.save()

  // 更新 OrderBook 的 filledTxHash
  let orderId = event.params.orderId
  let orderEntity = OrderBook.load(orderId)

  if (orderEntity) {
    // 更新 filledTxHash
    orderEntity.filledTxHash = event.transaction.hash

    // 保存更新后的 OrderBook 实体
    orderEntity.save()
  }

}


