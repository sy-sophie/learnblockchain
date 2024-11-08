// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "./interface/IMintingNFT.sol";
import "./ERC20_Token.sol";
import "./ERC721_NFT.sol";

contract AirdopMerkleNFTMarket is Ownable, EIP712 {
    NcNFT public nftContract;
    NCToken public tokenContract;
    bytes32 public merkleRoot;

    mapping(uint256 => NFTOrder) public listings;

    error InvalidSigner(address signer, address projectOwner);
    constructor(NcNFT _nftContract, NCToken _tokenContract, bytes32 _merkleRoot) EIP712("AirdopMerkleNFTMarket", "1") Ownable(msg.sender)  {
        nftContract = _nftContract;
        tokenContract = _tokenContract;
        merkleRoot = _merkleRoot;
    }
    // Mint and list NFT
    function mintNFTThroughMarket(address recipient, string memory metadataURI, uint256 price) external returns (uint256) {
        IMintingNFT mintingNFT = IMintingNFT(address(nftContract));
        uint256 newTokenId = mintingNFT.mintNFT(recipient, metadataURI);
        listings[newTokenId] = NFTOrder(msg.sender, price);
        return newTokenId;
    }

    function permitPrePay(NFTOrder calldata order, address user, bytes32[] calldata proof, bytes memory _signature,  uint256 deadline) public {
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }
        uint256 price = getDiscountedPrice(user, proof, order.price);
        tokenContract.permit(user, address(this), order.price, deadline, v, r, s);
    }


    function claimNFT(address user, uint256 nftId, bytes32[] calldata proof, NFTOrder calldata order) public {
        uint256 price = getDiscountedPrice(user, proof, order.price);
        require(tokenContract.balanceOf(user) >= price, "Insufficient balance");
        require(tokenContract.allowance(user, address(this)) >= price, "Insufficient allowance");
//
        tokenContract.transferFrom(user, order.maker, price);
        nftContract.safeTransferFrom(order.maker, user, nftId);
    }

    /**
       * @notice Call multiple contract static methods in batch
        * @param targets Target contract addresses array
        * @param data Data array for the calls
        * @return results Results array, a byte array
    */
    function multicall(address[2] memory targets, bytes[2] memory data) external returns (bytes[] memory results) {
        require(targets.length == data.length, "Multicall: mismatched lengths");
        results = new bytes[](targets.length);

        for (uint i = 0; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].delegatecall(data[i]);
            require(success, "Multicall: staticcall failed");
            results[i] = result;
        }
    }
    // Check if a user is in the whitelist
    function isWhitelisted(address user, bytes32[] memory proof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user));
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }
    function getDiscountedPrice(address user, bytes32[] calldata proof, uint256 originalPrice) internal view returns (uint256) {
        require(isWhitelisted(user, proof), "User not in whitelist");
        uint256 price = originalPrice;

        if (isWhitelisted(user, proof)) {
            price = (originalPrice * (100 - 50)) / 100;
        }
        return price;
    }
    // Set the Merkle root, only the contract owner can modify
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    struct NFTOrder {
        address maker;
        uint256 price;
    }
}

