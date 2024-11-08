// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
interface IMintingNFT {
    function mintNFT(address recipient, string memory metadataURI) external returns (uint256);
}
