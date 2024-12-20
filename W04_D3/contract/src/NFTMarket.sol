// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket is Ownable(msg.sender), EIP712("OpenSpaceNFTMarket", "1") { // name: OpenSpaceNFTMarket，version：1
    address public constant ETH_FLAG = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 public constant feeBP = 30; // 30/10000 = 0.3%
    address public whiteListSigner;     // 白名单签名者地址
    address public feeTo;               // 收取费用的地址
    mapping(bytes32 => SellOrder) public listingOrders; // orderId -> order book   从订单 ID 到 出售订单
    mapping(address => mapping(uint256 => bytes32)) private _lastIds; //  nft -> lastOrderId

    struct SellOrder {
        address seller;
        address nft;
        uint256 tokenId;
        address payToken;
        uint256 price;
        uint256 deadline;
    }

    // 查询 NFT 的列出订单
    function listing(address nft, uint256 tokenId) external view returns (bytes32) {
        bytes32 id = _lastIds[nft][tokenId];
        return listingOrders[id].seller == address(0) ? bytes32(0x00) : id; // 如果没有卖家，则返回零 ID
    }

    function list(address nft, uint256 tokenId, address payToken, uint256 price, uint256 deadline) external {
        require(deadline > block.timestamp, "MKT: deadline is in the past");
        require(price > 0, "MKT: price is zero");
        require(payToken == ETH_FLAG || IERC20(payToken).totalSupply() > 0, "MKT: payToken is not valid");

        // safe check
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "MKT: not owner");
        // 检查 NFT 是否被批准给合约
        require(
            IERC721(nft).getApproved(tokenId) == address(this)
            || IERC721(nft).isApprovedForAll(msg.sender, address(this)),
            "MKT: not approved"
        );

        SellOrder memory order = SellOrder({
            seller: msg.sender,
            nft: nft,
            tokenId: tokenId,
            payToken: payToken,
            price: price,
            deadline: deadline
        });

        bytes32 orderId = keccak256(abi.encode(order));
        // safe check repeat list  检查是否重复列出
        require(listingOrders[orderId].seller == address(0), "MKT: order already listed");
        listingOrders[orderId] = order;
        _lastIds[nft][tokenId] = orderId; // reset
        emit List(nft, tokenId, orderId, msg.sender, payToken, price, deadline);
    }
    // 取消订单功能
    function cancel(bytes32 orderId) external {
        address seller = listingOrders[orderId].seller; // 获取订单卖家地址
        // safe check repeat list
        require(seller != address(0), "MKT: order not listed");
        require(seller == msg.sender, "MKT: only seller can cancel");
        delete listingOrders[orderId];
        emit Cancel(orderId);
    }

    function buy(bytes32 orderId) public payable {
        _buy(orderId, feeTo);
    }
    // 带有白名单签名的购买功能
    function buy(bytes32 orderId, bytes calldata signatureForWL) external payable {
        _checkWL(signatureForWL); // 检查白名单
        // trade fee is zero
        _buy(orderId, address(0)); // 调用内部购买功能
    }

    function _buy(bytes32 orderId, address feeReceiver) private {
        // 0. load order info to memory for check and read
        SellOrder memory order = listingOrders[orderId];

        // 1. check
        require(order.seller != address(0), "MKT: order not listed");
        require(order.deadline > block.timestamp, "MKT: order expired");

        // 2. remove order info before transfer
        delete listingOrders[orderId];
        // 3. trasnfer NFT
        IERC721(order.nft).safeTransferFrom(order.seller, msg.sender, order.tokenId);

        // 4. trasnfer token
        // fee 0.3% or 0
        uint256 fee = feeReceiver == address(0) ? 0 : order.price * feeBP / 10000;  // 计算手续费
        // safe check
        if (order.payToken == ETH_FLAG) {
            require(msg.value == order.price, "MKT: wrong eth value");
        } else {
            require(msg.value == 0, "MKT: wrong eth value");
        }
        _transferOut(order.payToken, order.seller, order.price - fee);
        if (fee > 0) _transferOut(order.payToken, feeReceiver, fee);

        emit Sold(orderId, msg.sender, fee);
    }

    function _transferOut(address token, address to, uint256 amount) private {
        if (token == ETH_FLAG) {
            // eth
            (bool success,) = to.call{value: amount}("");
            require(success, "MKT: transfer failed");
        } else {
            SafeERC20.safeTransferFrom(IERC20(token), msg.sender, to, amount);
        }
    }

    bytes32 constant WL_TYPEHASH = keccak256("IsWhiteList(address user)"); // 白名单类型哈希

    // 检查白名单签名的内部函数
    function _checkWL(bytes calldata signature) private view {
        // check whiteListSigner for buyer
        bytes32 wlHash = _hashTypedDataV4(keccak256(abi.encode(WL_TYPEHASH, msg.sender)));
        address signer = ECDSA.recover(wlHash, signature); // 从签名恢复签名者地址
        require(signer == whiteListSigner, "MKT: not whiteListSigner");
    }

    // admin functions  管理员功能
    function setWhiteListSigner(address signer) external onlyOwner {
        require(signer != address(0), "MKT: zero address");
        require(whiteListSigner != signer, "MKT:repeat set");
        whiteListSigner = signer;

        emit SetWhiteListSigner(signer);
    }

    function setFeeTo(address to) external onlyOwner {
        require(feeTo != to, "MKT:repeat set");
        feeTo = to;

        emit SetFeeTo(to);
    }

    event List(
        address indexed nft,
        uint256 indexed tokenId,
        bytes32 orderId,
        address seller,
        address payToken,
        uint256 price,
        uint256 deadline
    );
    event Cancel(bytes32 orderId);
    event Sold(bytes32 orderId, address buyer, uint256 fee);
    event SetFeeTo(address to);
    event SetWhiteListSigner(address signer);
}
