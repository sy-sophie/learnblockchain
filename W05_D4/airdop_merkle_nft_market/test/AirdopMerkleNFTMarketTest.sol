// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/ERC20_Token.sol";
import "../src/ERC721_NFT.sol";
import "../src/AirdopMerkleNFTMarket.sol";
import "../utils/SigUtils.sol";


contract AirdopMerkleNFTMarketTest is Test {
    NcNFT public nftContract;
    NCToken public tokenContract;
    AirdopMerkleNFTMarket airdopMerkleNFTMarket;
    SigUtils internal sigUtils;
    bytes32 public merkleRoot = 0x9734607f1e052213793490eb96b613a0fecb9f6e40d1ded7c97d0cd4dbb81e92;
    bytes32[] public proof = [bytes32(0x37d95e0aa71e34defa88b4c43498bc8b90207e31ad0ef4aa6f5bea78bd25a1ab), bytes32(0x4beda981c9d34f2dd099131be6049a1d87676d227e63f4a409ee629043314b4f)];
    uint256 internal seller1PK = 0x99999;
    uint256 internal buyer1PK = 0x44444;
    address seller1 = vm.addr(seller1PK);
    address buyer1 = vm.addr(buyer1PK);
    address buyer1_in_w = 0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9;  // Buyer, in whitelist

    function setUp() public {
        nftContract = new NcNFT();
        tokenContract = new NCToken();
        sigUtils = new SigUtils(tokenContract.DOMAIN_SEPARATOR());

        tokenContract.mint(buyer1_in_w, 1000 * 10 ** 18);


        airdopMerkleNFTMarket = new AirdopMerkleNFTMarket(nftContract, tokenContract, merkleRoot);

    }

    function test_Airdrop() public {
        uint256 depositAmount = 60;
        // Seller 1: Mint NFT and list it on the market
        vm.startPrank(seller1);
        uint256 tokenId = airdopMerkleNFTMarket.mintNFTThroughMarket(seller1, "https://example.com/metadata.json", depositAmount);
        assertEq(nftContract.ownerOf(tokenId), seller1);
        nftContract.approve(address(airdopMerkleNFTMarket), tokenId);
        vm.stopPrank();

        // Buy NFT
        vm.startPrank(buyer1_in_w);
        uint256 deadline = block.timestamp + 1 days;
        uint256 nonce = tokenContract.nonces(buyer1_in_w);
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: buyer1_in_w,
            spender: address(airdopMerkleNFTMarket),
            value: depositAmount,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 typedDataHash = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyer1PK, typedDataHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        vm.stopPrank();


        bytes memory permitPrePayData = abi.encodeWithSelector(
            airdopMerkleNFTMarket.permitPrePay.selector,
            AirdopMerkleNFTMarket.NFTOrder(seller1, depositAmount),
            buyer1_in_w,
            proof,
            signature,
            deadline
        );

        bytes memory claimNFTData = abi.encodeWithSelector(
            airdopMerkleNFTMarket.claimNFT.selector,
            buyer1_in_w,
            tokenId,
            proof,
            AirdopMerkleNFTMarket.NFTOrder(seller1, depositAmount)
        );

        // 调用 multicall
        bytes[] memory results = airdopMerkleNFTMarket.multicall([permitPrePayData, claimNFTData]
        );
        assertEq(nftContract.ownerOf(tokenId), buyer1_in_w);


        vm.stopPrank();

    }
}
