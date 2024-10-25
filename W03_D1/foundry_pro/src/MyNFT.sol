// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MyToken.sol"; // 引入 MyToken 合约

contract MyNFT is ERC721Enumerable {
    uint256 public currentTokenId;
    MyToken public token; // MyToken 实例
    uint256 public price = 1 * 10**18; // NFT 的价格（以 MyToken 的最小单位表示）

    constructor(address tokenAddress) ERC721("MyNFT", "MNFT") {
        token = MyToken(tokenAddress);
    }

    function mint(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
        currentTokenId = tokenId + 1; // 更新当前 token ID
    }
}
