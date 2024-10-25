// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./MyToken.sol";
import "../src/MyNFT.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "forge-std/console.sol";

contract NFTMarket is EIP712 {
    using ECDSA for bytes32;

    MyToken public paymentToken;
    MyNFT public nftContract;
    address public projectOwner; // 在合约中定义项目方地址

    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address buyer,uint256 tokenId,uint256 deadline)");
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");
    bytes32 public DOMAIN_SEPARATOR;

    error ExpiredSignature(uint256 deadline);
    error InvalidSigner(address signer, address projectOwner);
    constructor(MyNFT _nftContract, MyToken _paymentToken, address _projectOwner) EIP712("NFTMarket", "1") {
        nftContract = _nftContract;
        paymentToken = _paymentToken;
        projectOwner = _projectOwner;

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            PERMIT_TYPEHASH, // type hash
            keccak256(bytes("EIP712Storage")), // name
            keccak256(bytes("1")), // version
            block.chainid, // chain id
            address(this) // contract address
        ));
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

    function permitBuy(address buyer,uint256 tokenId, uint256 amount, uint256 deadline, bytes memory _signature) external {
        // 验签
        verifySignTwo(msg.sender, tokenId, deadline, _signature);

        Listing memory listing = listings[tokenId];
        require(amount >= listing.price, "Insufficient funds");

        // 检查买家的代币余额是否足够
        uint256 buyerBalance = paymentToken.balanceOf(buyer);
        require(buyerBalance >= listing.price, "Buyer does not have enough tokens");

        // 检查买家是否已授权 NFTMarket 合约足够的代币
        uint256 allowance = paymentToken.allowance(buyer, address(this));
        require(allowance >= listing.price, "Insufficient allowance");

        paymentToken.transferFrom(buyer, listing.seller, listing.price);
        nftContract.transferFrom(listing.seller, buyer, tokenId);

        delete listings[tokenId]; // Remove the listing after purchase
    }

    function verifySignTwo(address buyer, uint256 tokenId, uint256 deadline, bytes memory _signature) public {
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
        /*
        前32 bytes存储签名的长度 (动态数组存储规则)
        add(sig, 32) = sig的指针 + 32
        等效为略过signature的前32 bytes
        mload(p) 载入从内存地址p起始的接下来32 bytes数据
        */
        // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
        // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
        // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 获取签名消息hash
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                STORAGE_TYPEHASH,
                buyer,
                tokenId,
                deadline
            ))
        ));
        address signer = digest.recover(v, r, s); // 恢复签名者
        if (signer != projectOwner) { // 要等于 项目方 地址
            revert InvalidSigner(signer, projectOwner);
        }
    }

    function verifySign(address buyer, uint256 tokenId, uint256 deadline, uint8 v,
        bytes32 r,
        bytes32 s) internal {
        if (block.timestamp > deadline) {
            revert ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, buyer, projectOwner, tokenId, deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s); // signer
        if (signer != projectOwner) { // 要等于 项目方 地址
            revert InvalidSigner(signer, projectOwner);
        }
    }

}
