// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IMintingNFT.sol";

contract NcNFT is ERC721URIStorage, Ownable, IMintingNFT {
    uint256 public tokenCounter;

    constructor() ERC721("MintingNFT", "MNFT") Ownable(msg.sender) {
        tokenCounter = 0;
    }
    function mintNFT(address recipient, string memory metadataURI) public returns (uint256) {
        uint256 newTokenId = tokenCounter;
        tokenCounter++;

        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, metadataURI);

        return newTokenId;
    }
}
