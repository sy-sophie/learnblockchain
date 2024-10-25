// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";
import "../utils/NFTSigUtils.sol";

contract NFTMarketTest is Test {
    NFTSigUtils internal nftSigUtils;

    MyToken public mToken;
    MyNFT public mNFT;
    NFTMarket public nftMarket;

    address internal projectOwner;
    address public buyer;
    address public seller;

    uint256 internal initialSupply = 1000 * 10 ** 18;

    function setUp() public {
        // 设置初始账户和合约
        projectOwner = vm.addr(0x123);
        buyer = vm.addr(0x456);
        seller = vm.addr(0x789);


        mToken = new MyToken(initialSupply);
        mNFT = new MyNFT(address(mToken));
        nftMarket = new NFTMarket(mNFT, mToken, projectOwner);

        // 分配代币给买家
        vm.prank(address(this));
        mToken.transfer(buyer, initialSupply);

        // 设置买家对市场合约的代币授权
        vm.prank(buyer);
        mToken.approve(address(nftMarket), initialSupply); // 授权买家将所有代币转移到市场合约

        // 卖家铸造 NFT 并上架
        vm.startPrank(seller);
        mNFT.mint(1);
        mNFT.mint(2);

        mNFT.approve(address(nftMarket), 1);
        mNFT.approve(address(nftMarket), 2);

        nftMarket.listNFT(1, 2000);
        nftMarket.listNFT(2, 4000);

        vm.stopPrank();

    }

    function testPermitBuy() public {
        nftSigUtils = new NFTSigUtils(nftMarket.DOMAIN_SEPARATOR());

        uint256 tokenId = 1;
        uint256 deadline = block.timestamp + 1 days;
        uint256 price = 2000;
        // 创建许可数据
        NFTSigUtils.Permit memory permit = NFTSigUtils.Permit({
            buyer: buyer,
            tokenId: tokenId,
            deadline: deadline
        });

        vm.startPrank(projectOwner);
        bytes32 typedDataHash = nftSigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x123, typedDataHash); //  买家的私钥 + 消息

        bytes memory signature = abi.encodePacked(r, s, v);
        vm.stopPrank();

        // 使用签名来购买 NFT
        vm.prank(buyer);
        nftMarket.permitBuy(buyer,tokenId, price, deadline, signature);

        // 验证 NFT 是否成功转移
        assertEq(mNFT.ownerOf(tokenId), buyer, "NFT should be transferred to buyer");

        // 验证支付是否成功
        assertEq(mToken.balanceOf(seller), price, "Seller should receive payment");
    }
}

