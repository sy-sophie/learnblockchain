// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/ERC20_Token.sol";
import "../src/ERC721_NFT.sol";
import "../src/AirdopMerkleNFTMarket.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";


contract AirdopMerkleNFTMarketTest is Test {
    IERC721 public nftContract;    // NFT 合约地址
    IERC20 public tokenContract;
    address  public proxyAddress; // Airdop 合约地址
    AirdopMerkleNFTMarket airdopNFTMarketProxy;

    uint256 internal seller1PK = 0x99999;
    address seller1 = vm.addr(seller1PK);  // 卖方
    address buyer1_in_w = vm.addr(0x123);  // 买方，在白名单里
    address buyer2 = vm.addr(3);  // 买方

    address [] public whitelist = [vm.addr(0x111111), vm.addr(0x222222), vm.addr(0x333333), buyer1_in_w];
    bytes32 public merkleRoot;     // 白名单根
    bytes32[] public proofForBuyer1; // 用于 buyer1_in_w 的 Merkle 证明
    function setUp() public {
        nftContract = new NcNFT();
        tokenContract = new NCToken();

        // 构建 Merkle Tree
        bytes32[] memory leaves = new bytes32[](whitelist.length);
        for (uint i = 0; i < whitelist.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(whitelist[i]));
        }

        merkleRoot = computeMerkleRoot(leaves);
        // 生成 buyer1_in_w 的 Merkle 证明
        proofForBuyer1 = generateProof(keccak256(abi.encodePacked(buyer1_in_w)), leaves);

        proxyAddress = Upgrades.deployUUPSProxy(
            "AirdopMerkleNFTMarket.sol",
            abi.encodeCall(AirdopMerkleNFTMarket.initialize, (nftContract, tokenContract, merkleRoot))
        );
        airdopNFTMarketProxy = AirdopMerkleNFTMarket(proxyAddress);

    }
    //  卖方1：铸造NFT，对 NFT 签名 = NFT上架
    //  买方1：在白名单里，调用 multicall，半价购买 NFT
    //  买方2：不在白名单里，调用 multicall，全价购买 NFT
    function test_Airdrop() public {
        //  卖方1：铸造NFT
        vm.startPrank(seller1);  // 模拟卖方1作为调用者
        uint256 tokenId = airdopNFTMarketProxy.mintNFTThroughMarket(seller1, "https://example.com/metadata.json");
        assertEq(nftContract.ownerOf(tokenId), seller1); // 检查NFT是否已铸造，并分配给卖方1

        // 卖方1：签名，上架NFT
        AirdopMerkleNFTMarket.NFTOrder memory nftOrder = AirdopMerkleNFTMarket.NFTOrder({
            maker: seller1,
            nft_ca: address(nftContract),
            token_id: tokenId,
            price: 60
        });
        bytes32 hashStruct = airdopNFTMarketProxy.orderHash(nftOrder);
        bytes32 permitHash = keccak256(abi.encodePacked("\x19\x01", airdopNFTMarketProxy.getDomain(), hashStruct));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(seller1PK, permitHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v)); // bytes memory signature = abi.encodePacked(r, s, v)
        vm.stopPrank();

        bytes memory permitPrePayData = abi.encodeWithSignature(
            "permitPrePay((address,address,uint256,uint256),bytes)",
            nftOrder,
            signature
        );
        bytes memory claimNFTData = abi.encodeWithSignature(
            "claimNFT(bytes32[],address,(address,address,uint256,uint256))",
            proofForBuyer1,
            buyer1_in_w,
            nftOrder
        );

        address[2] memory targets;
        targets[0] = address(airdopNFTMarketProxy);
        targets[1] = address(airdopNFTMarketProxy);

        bytes[2] memory data;
        data[0] = permitPrePayData;
        data[1] = claimNFTData;

        bytes[] memory results = airdopNFTMarketProxy.multicall(
            targets,
            data
        );
//        assertEq(nftContract.ownerOf(tokenId), buyer1_in_w);
    }

    function computeMerkleRoot(bytes32[] memory leaves) internal pure returns (bytes32) {
        uint256 len = leaves.length;

        while (len > 1) {
            uint256 nextLen = (len + 1) / 2;
            bytes32[] memory nextLevel = new bytes32[](nextLen);

            for (uint256 i = 0; i < len / 2; i++) {
                nextLevel[i] = keccak256(abi.encodePacked(leaves[i * 2], leaves[i * 2 + 1]));
            }

            if (len % 2 == 1) {
                nextLevel[nextLen - 1] = leaves[len - 1];
            }

            leaves = nextLevel;
            len = nextLen;
        }

        return leaves[0];
    }

    function generateProof(bytes32 leaf, bytes32[] memory leaves) internal pure returns (bytes32[] memory) {
        // 实现生成 Merkle 证明的逻辑
        uint256 index = findLeafIndex(leaf, leaves);
        require(index != leaves.length, "Leaf not found in tree");

        // 创建一个合适大小的 proof 数组
        uint256 proofLength = leaves.length - 1;  // Merkle 树的高度决定了证明的长度
        bytes32[] memory proof = new bytes32[](proofLength);

        uint256 proofIndex = 0;
        for (uint256 i = 0; i < leaves.length; i++) {
            if (i != index) {
                proof[proofIndex++] = leaves[i];
            }
        }

        return proof;
    }

    function findLeafIndex(bytes32 leaf, bytes32[] memory leaves) internal pure returns (uint256) {
        for (uint256 i = 0; i < leaves.length; i++) {
            if (leaves[i] == leaf) {
                return i;
            }
        }
        return leaves.length;
    }
}
