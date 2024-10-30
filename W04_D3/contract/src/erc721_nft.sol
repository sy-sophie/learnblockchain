// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 public currentTokenId; // 当前 NFT 的 ID

    constructor() ERC721("MyNFT", "MNFT"){}

    // 铸造 NFT
    function mint() external {
        currentTokenId++; // 增加 NFT ID
        _mint(msg.sender, currentTokenId); // 将 NFT 铸造给合约所有者
    }

}
