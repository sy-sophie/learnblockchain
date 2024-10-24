// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./MyToken.sol";
import "../src/MyNFT.sol";
import "./IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

// project owner
contract NFTMarket is IERC777Recipient, EIP712 {
    using ECDSA for bytes32;

    MyToken public paymentToken;
    MyNFT public nftContract;
    address public projectOwner; // 在合约中定义项目方地址

    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;

    bytes32 private constant PERMIT_TYPEHASH = keccak256("Permit(address buyer,address projectOwner,uint256 tokenId,uint256 nonce,uint256 deadline)");

    error ExpiredSignature(uint256 deadline);
    error InvalidSigner(address signer, address owner);
    constructor(MyNFT _nftContract, MyToken _paymentToken, address _projectOwner) EIP712("NFTMarket", "1") {
        nftContract = _nftContract;
        paymentToken = _paymentToken;
        projectOwner = _projectOwner;
    }

    // @param nftContract  NFT 合约的地址
    // @param tokenId      要出售的 NFT 的 ID
    function listNFT(uint256 tokenId, uint256 price) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not the owner");
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

    function permitBuy(uint256 tokenId, uint256 amount, uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s) external {
        uint256 nonce = paymentToken.nonces(msg.sender); // 获取用户的 nonce
        // 验签
        verifySign(msg.sender, tokenId, nonce, deadline, v, r, s);

        Listing memory listing = listings[tokenId];
        require(amount >= listing.price, "Insufficient funds");

        paymentToken.transferFrom(msg.sender, listing.seller, listing.price);
        nftContract.transferFrom(listing.seller, msg.sender, tokenId);

        delete listings[tokenId]; // Remove the listing after purchase
    }

    function verifySign(address buyer, uint256 tokenId,uint256 nonce,uint256 deadline, uint8 v,
        bytes32 r,
        bytes32 s) internal {
        if (block.timestamp > deadline) {
            revert ExpiredSignature(deadline);
        }
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, buyer, projectOwner, tokenId, nonce, deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != projectOwner) { // 要等于 项目方 地址
            revert InvalidSigner(signer, projectOwner);
        }
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
