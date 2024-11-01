// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../src/NFTFactory.sol";

contract DeployAndMintNFT {

    function run() external {
        // 部署 NFTFactory
        NFTFactory factory = new NFTFactory();

        // 部署新的 NFT 合约
        address nftAddress = factory.deployNFT("MyNFT", "MNFT", "ipfs://", 100);
        S2NFT nft = S2NFT(nftAddress);

        nft.mintNFT(4); // 为调用者铸造2个NFT
    }


}
