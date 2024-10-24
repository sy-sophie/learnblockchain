// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./MyToken.sol";
import "../src/MyNFT.sol";
import "./IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarket is IERC777Recipient {
    using ECDSA for bytes32;

    MyToken public paymentToken;
    MyNFT public nftContract;

    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;
    mapping(address => bool) public whitelist;
    mapping(bytes => bool) public usedSignatures;


    constructor(MyNFT _nftContract, MyToken _paymentToken) {
        nftContract = _nftContract;
        paymentToken = _paymentToken;
    }

    // @param nftContract  NFT 合约的地址
    // @param tokenId      要出售的 NFT 的 ID
    function listNFT(uint256 tokenId, uint256 price) public {
        require(nftContract.ownerOf(tokenId) == msg.sender,"Not the owner");
        // msg.sender（即 NFT 的拥有者）是否已经将所有的 NFT 批量授权给当前合约 (address(this)) || 检查指定的 NFT（tokenId）是否单独授权给当前合约 (address(this)) 操作。
        require(nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(tokenId) == address(this), "NFT not approved");

        listings[tokenId] = Listing(msg.sender, price);
    }

    // @param tokenId       要购买的 NFT 的 ID
    // @param amount        买家支付的代币数量
    // @param erc20Token    用于支付的 ERC20 代币的合约地址
    function buyNFT(uint256 tokenId, uint256 amount) public {
        Listing memory listing = listings[tokenId];
        require(amount >= listing.price, "Insufficient funds");

        paymentToken.transferFrom(msg.sender, listing.seller, listing.price);
        nftContract.transferFrom(listing.seller, msg.sender, tokenId);

        delete listings[tokenId]; // Remove the listing after purchase
    }
    function permitBuy(address buyer, bytes memory signature, uint256 tokenId, uint256 amount) external{
        require(whitelist[buyer], "Not whitelisted");  // 确保购买者在白名单中

        bytes32 messageHash = keccak256(abi.encodePacked(buyer));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash); // Convert to eth signed message hash
        address signer = ECDSA.recover(ethSignedMessageHash, signature); // Recover the signer
        require(signer == msg.sender, "Invalid signature");

        Listing memory listing = listings[tokenId];
        require(amount >= listing.price, "Insufficient funds");

        paymentToken.transferFrom(buyer, listing.seller, listing.price);
        nftContract.transferFrom(listing.seller, buyer, tokenId);

        delete listings[tokenId]; // Remove the listing after purchase


        usedSignatures[signature] = true;
    }

    function addToWhitelist(address user) external {
        whitelist[user] = true;
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        require(msg.sender == address(paymentToken), "Invalid sender");

        uint256 tokenId = abi.decode(userData, (uint256));
        Listing memory listing = listings[tokenId];

        require(listing.price > 0, "This NFT is not for sale.");
        require(amount >= listing.price, "Insufficient funds");

        paymentToken.transferFrom(from, listing.seller, listing.price);
        nftContract.safeTransferFrom(listing.seller, from, tokenId);

        delete listings[tokenId];
    }


}
