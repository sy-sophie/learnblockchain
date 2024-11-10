// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IMintingNFT.sol";

contract AirdopMerkleNFTMarket is OwnableUpgradeable, EIP712Upgradeable {
    IERC721 public nftContract;  // 铸造合约的地址
    IERC20 public tokenContract; // Token合约地址
    bytes32 public merkleRoot;// 白名单的 merkleRoot
    bytes32 public constant PERMIT_TYPEHASH = keccak256("NFTOrder(address maker,address nft_ca,uint256 token_id,uint256 price)");

    uint256 public discount; // 打折百分比，假设50%优惠


    function initialize(IERC721 _nftContract, IERC20 _tokenContract, bytes32 _merkleRoot) public initializer {  // 设置铸造合约的地址
        __Ownable_init(msg.sender);
        __EIP712_init("AirdopMerkleNFTMarket", "1");
        nftContract = _nftContract;
        tokenContract = _tokenContract;
        merkleRoot = _merkleRoot;
        discount = 50;
    }

    function mintNFTThroughMarket(address recipient, string memory metadataURI) external returns (uint256) {  // 调用铸造合约铸造NFT
        // 通过铸造合约铸造NFT
        IMintingNFT mintingNFT = IMintingNFT(address(nftContract));
        uint256 newTokenId = mintingNFT.mintNFT(recipient, metadataURI);
        return newTokenId;
    }

    // 设置Merkle树根，只有合约所有者可以修改
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    // 验签，NFT是否合法等
    function permitPrePay(NFTOrder calldata order, bytes calldata makerSignature) internal {
        // 验证签名 _verify
        require(_verify(order, makerSignature), "Invalid signature");

    }
    // 验白名单，是否享受 50%价格，收token卖NFT
    function claimNFT(bytes32[] memory proof, address user, NFTOrder calldata order) internal {
        require(isWhitelisted(user, proof), "User is not whitelisted");  // 验证用户是否在白名单中
        // TODO 2. 获取 NFT 的价格，这里假设价格是一个固定值，你可以根据需要调整
//        uint256 nftPrice = 1 ether; // 假设每个NFT的价格是 1 Token
//        uint256 discountedPrice = nftPrice * (100 - discount) / 100; // 获取折扣后的价格

//        ERC20(tokenContract).transferFrom(user, address(this), discountedPrice); // TODO 从用户账户转移代币到市场合约

//        ERC721URIStorage(nftContract).safeTransferFrom(address(this), user, tokenId); // 从市场合约转移 NFT 给用户
    }

    // 检查用户是否在白名单中
    function isWhitelisted(address user, bytes32[] memory proof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user));
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    /**
        * @notice 批量调用多个合约的静态方法
        * @param targets 目标合约地址数组
        * @param data 调用数据数组
        * @return results 返回结果数组，一个字节数组
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

    struct NFTOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 price; // 租金
    }

    function orderHash(NFTOrder calldata order) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                order.maker,
                order.nft_ca,
                order.token_id,
                order.price
            ))
        );
    }

    function getDomain() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _verify(NFTOrder calldata order, bytes memory signature) internal view returns (bool) {
        bytes32 hashStruct = orderHash(order);
        bytes32 sig = keccak256(abi.encodePacked("\x19\x01", getDomain(), hashStruct));
        return order.maker == ECDSA.recover(sig, signature);
    }
}

// 合约升级时不允许使用 delegatecall
