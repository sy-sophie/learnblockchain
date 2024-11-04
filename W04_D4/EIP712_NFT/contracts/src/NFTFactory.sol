// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract S2NFT is ERC721Enumerable {
    string private _BASE_URI; // 存储基本URI，用于获取NFT元数据的地址

    uint256 private _nextTokenId = 0; // 记录下一个要铸造的Token ID
    uint256 public immutable MAX_SUPPLY; // 最大供应量

    constructor(string memory name_, string memory symbol_, string memory baseURI_, uint256 maxSupply_) // 初始化名称、符号、基本URI和最大供应量
    ERC721(name_, symbol_) // 调用ERC721构造函数
    {
        _BASE_URI = baseURI_; // 设置基本URI
        MAX_SUPPLY = maxSupply_; // 设置最大供应量
    }

    function _baseURI() internal view override returns (string memory) { // 重写ERC721的_baseURI方法，返回基本URI
        return _BASE_URI;
    }
//    function mintNFT(string memory tokenURI) public returns (uint256) {
//        uint256 tokenId = _nextTokenId;
//        _nextTokenId++;
//
//        _safeMint(msg.sender, tokenId);
//        _setTokenURI(tokenId, tokenURI);
//
//        return tokenId;
//    }

    function freeMint(uint256 amount) external { // 免费铸造函数，允许用户铸造指定数量的NFT
        require(amount <= 5, "You can mint up to 5 tokens at a time"); // 限制每次最多铸造5个Token
        uint256 nextTokenId = _nextTokenId; // 获取当前Token ID
        for (uint256 i = 0; i < amount; i++) { // 循环铸造指定数量的NFT
            _safeMint(msg.sender, nextTokenId); // 铸造NFT并安全转移给调用者
            nextTokenId++; // 更新Token ID
        }
        _nextTokenId = nextTokenId; // 更新下一个要铸造的Token ID
        require(_nextTokenId <= MAX_SUPPLY, "All tokens have been minted"); // 确保不超过最大供应量
    }
}

contract NFTFactory is Ownable(msg.sender) { // 创建NFTFactory合约，继承自Ownable
    event NFTCreated(address nftCA); // NFT创建事件
    event NFTRegesitered(address nftCA); // NFT注册事件

    mapping(address => bool) regesiteredNFTs; // 记录注册的NFT地址

    function deployNFT(string memory name, string memory symbol, string memory baseURI, uint256 maxSupply) // 部署新的NFT合约并返回其地址
    external returns (address){
        S2NFT nft = new S2NFT(name, symbol, baseURI, maxSupply); // 创建新的S2NFT合约实例
        regesiteredNFTs[address(nft)] = true; // 标记NFT为已注册
        emit NFTCreated(address(nft));  // 触发NFT创建事件
        return address(nft); // 返回NFT合约地址
    }

    function regesiterNFT(address nftCA) external onlyOwner { // 注册现有的NFT合约
        require(!regesiteredNFTs[nftCA], "NFT already regesitered"); // 确保NFT未被注册
        regesiteredNFTs[nftCA] = true; // 标记NFT为已注册
        emit NFTRegesitered(nftCA); // 触发NFT注册事件
    }
}
