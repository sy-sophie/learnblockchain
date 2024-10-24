// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";
import "../utils/NFTSigUtils.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


contract NFTMarketTest is Test {
    MyToken public mToken;
    MyNFT public mNFT;
    NFTMarket public nftMarket;
    NFTSigUtils internal nftSigUtils;

    uint256 internal initialSupply = 1000 * 10 ** 18;

    // 购买者 buyer
    uint256 internal buyerPrivateKey;
    address internal buyer;

    // 项目方 projectOwner
    uint256 internal projectOwnerPrivateKey;
    address internal projectOwner;

    // signature
    bytes internal signature;

    function setUp() public {
        buyerPrivateKey = 0xA11CE;
        buyer = vm.addr(buyerPrivateKey);
        projectOwnerPrivateKey = 0xB0B;
        projectOwner = vm.addr(projectOwnerPrivateKey);

        // 1. MyToken：initialSupply(发行量)
        // 2. MyNFT：MyToken地址(使用MyToken购买)
        // 3. NFTMarket：MyToken地址，MyNFT
        mToken = new MyToken(initialSupply);
        mNFT = new MyNFT(address(mToken));
        nftMarket = new NFTMarket(mNFT, mToken, projectOwner);
        nftSigUtils = new NFTSigUtils(mToken.DOMAIN_SEPARATOR());

        // 4. 项目方 铸造 MyNF
        vm.startPrank(projectOwner);
        mNFT.setApprovalForAll(address(nftMarket), true);
        mNFT.mint(1);
        mNFT.mint(2);

        // 5. 项目方 在 NFTMarket 上架
        nftMarket.listNFT(1, 2000);
        nftMarket.listNFT(2, 4000);
        vm.stopPrank();

        // 6. 给 购买者 buyer 钱 mToken.mint
        mToken.transfer(buyer, initialSupply);
    }

    function testPermitBuy() public {
        uint256 deadline = block.timestamp + 1 days; // 设置许可的截止时间
        uint256 nonce = mToken.nonces(buyer); // 获取用户的 nonce
        // 创建许可数据
        NFTSigUtils.Permit memory permit = NFTSigUtils.Permit({
            buyer: buyer,
            projectOwner: projectOwner,
            tokenId: 1,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 typedDataHash = nftSigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPrivateKey, typedDataHash);

        // buyer nftMarket.permitBuy 购买
        vm.startPrank(buyer);
        nftMarket.permitBuy( 1, 2000, deadline,v, r, s);
        vm.stopPrank();

        // 项目方 是否 收到 钱
        console.log("mToken.balanceOf(projectOwner)", mToken.balanceOf(projectOwner));
        assertEq(mToken.balanceOf(projectOwner), 2000);

        // buyer 是否收到 nft
        console.log("mNFT.ownerOf(1)", mNFT.ownerOf(1));
        assertEq(mNFT.ownerOf(1), buyer);

    }
}
