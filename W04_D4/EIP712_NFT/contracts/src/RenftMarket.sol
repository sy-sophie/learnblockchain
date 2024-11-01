// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title RenftMarket
 * @dev NFT租赁市场合约
 *   TODO:
 *      1. 退还NFT：租户在租赁期内，可以随时退还NFT，根据租赁时长计算租金，剩余租金将会退还给出租人
 *      2. 过期订单处理：
 *      3. 领取租金：出租人可以随时领取租金
 */
contract RenftMarket is EIP712 {
    // 出租订单事件
    event BorrowNFT(address indexed taker, address indexed maker, bytes32 orderHash, uint256 collateral);
    // 取消订单事件
    event OrderCanceled(address indexed maker, bytes32 orderHash);


    mapping(bytes32 => BorrowOrder) public orders; // 已租赁订单
    mapping(bytes32 => bool) public canceledOrders; // 已取消的挂单

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)");
    bytes32 public constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");
    bytes32 public DOMAIN_SEPARATOR;

    constructor() EIP712("RenftMarket", "1") {

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            PERMIT_TYPEHASH, // type hash
            keccak256(bytes("EIP712Storage")), // name
            keccak256(bytes("1")), // version
            block.chainid, // chain id
            address(this) // contract address
        ));
    }

    /**
     * @notice 租赁NFT
   * @dev 验证签名后，将NFT从出租人转移到租户，并存储订单信息
   */
    function borrow(RentoutOrder calldata order, bytes memory makerSignature) external payable {
        require(verify(order, makerSignature), "Invalid signature");

        // Verify order validity
        require(!canceledOrders[orderHash(order)], "Order has been canceled");
        require(orders[orderHash(order)].taker == address(0), "Order has been taken");

        require(msg.value >= order.min_collateral, "Insufficient collateral");

        require(order.max_rental_duration > 0, "Invalid rental duration");

        require(block.timestamp < order.list_endtime, "Order has expired");


        IERC721(order.nft_ca).safeTransferFrom(order.maker, msg.sender, order.token_id);


        payable(order.maker).transfer(msg.value);


        BorrowOrder memory newOrder = BorrowOrder({ // 记录新订单
            taker: msg.sender,
            collateral: msg.value,
            start_time: block.timestamp,
            rentinfo: order
        });

        orders[orderHash(order)] = newOrder;

        emit BorrowNFT(msg.sender, order.maker, orderHash(order), msg.value);
    }

    /**
     * 1. 取消时一定要将取消的信息在链上标记，防止订单被使用！
     * 2. 防DOS： 取消订单有成本，这样防止随意的挂单，
     */
    function cancelOrder(RentoutOrder calldata order, bytes calldata makerSignature) external {
        require(verify(order, makerSignature), "Invalid signature");
        canceledOrders[orderHash(order)] = true;
        emit OrderCanceled(order.maker, orderHash(order));
    }

    // 计算订单哈希
    function orderHash(RentoutOrder calldata order) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                STORAGE_TYPEHASH,
                order.maker,
                order.nft_ca,
                order.token_id,
                order.daily_rent,
                order.max_rental_duration,
                order.min_collateral,
                order.list_endtime
            ))
        ));
    }

    function verify( RentoutOrder calldata order, bytes memory _signature) internal view returns (bool) {
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))  // 读取长度数据后的32 bytes
            s := mload(add(_signature, 0x40))  // 读取之后的32 bytes
            v := byte(0, mload(add(_signature, 0x60))) // 读取最后一个byte
        }
        // 获取签名消息hash
        bytes32 digest = orderHash(order);
        address signer = ECDSA.recover(digest, v, r, s); // 恢复签名者 address signer = digest.recover(v, r, s);
        return signer == order.maker; // 验证签名者是否为出租方
//        return true;
    }

}

    struct RentoutOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 daily_rent; // 每日租金
        uint256 max_rental_duration; // 最大租赁时长
        uint256 min_collateral; // 最小抵押
        uint256 list_endtime; // 挂单结束时间
    }

// 租赁信息
    struct BorrowOrder {
        address taker; // 租方人地址
        uint256 collateral; // 抵押
        uint256 start_time; // 租赁开始时间，方便计算利息
        RentoutOrder rentinfo; // 租赁订单
    }
