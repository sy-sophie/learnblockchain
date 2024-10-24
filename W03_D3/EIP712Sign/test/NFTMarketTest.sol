// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


contract NFTMarketTest is Test {
    MyToken public mToken;
    MyNFT public mNFT;
    NFTMarket public nftMarket;

    uint256 initialSupply = 1000 * 10 ** 18;

    // 购买者 buyer
    uint256 internal buyerPrivateKey;
    address internal buyer;

    // 项目方 projectSide
    address projectSide = address(0x1);

    // signature
    bytes internal signature;

    function setUp() public {
        // 1. MyToken：initialSupply(发行量)
        // 2. MyNFT：MyToken地址(使用MyToken购买)
        // 3. NFTMarket：MyToken地址，MyNFT
        mToken = new MyToken(initialSupply);
        mNFT = new MyNFT(address(mToken));
        nftMarket = new NFTMarket(mNFT, mToken);

        // 4. 项目方 铸造 MyNFT
        vm.startPrank(projectSide);
        mNFT.mint(1);
        mNFT.mint(2);

        // 5. 授权 NFTMarket 管理 MyNFT TODO
        mNFT.setApprovalForAll(address(nftMarket), true);
        // 6. 项目方 在 NFTMarket 上架
        nftMarket.listNFT(1, 2000);
        nftMarket.listNFT(2, 4000);
        vm.stopPrank();

        // 7. 给 购买者 buyer 钱 mToken.mint
        buyerPrivateKey = 0xA11CE;
        buyer = vm.addr(buyerPrivateKey);
        mToken.transfer(buyer, initialSupply);

        // 8. 给予 NFTMarket 购买者的授权
        vm.startPrank(buyer);
        mToken.approve(address(nftMarket), initialSupply);
        vm.stopPrank();

        // 9. 生成签名
        // 这里我们可以直接在合约中生成签名，通常在实际应用中，签名是在 off-chain 生成的
        bytes32 messageHash = keccak256(abi.encodePacked(buyer));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPrivateKey, ethSignedMessageHash);
        signature = abi.encodePacked(r, s, v); // 将签名组合成 bytes 类型
    }

    function testPermitBuy() public {
        // 项目方 把 buyer 放到白名单中，nftMarket.
        vm.startPrank(projectSide);
        nftMarket.addToWhitelist(buyer);
        vm.stopPrank();

        // buyer nftMarket.permitBuy 购买
        vm.startPrank(buyer);
        nftMarket.permitBuy(buyer, signature, 1, 2000);
        vm.stopPrank();

        // 项目方 是否 收到 钱
        console.log("mToken.balanceOf(projectSide)", mToken.balanceOf(projectSide));
        assertEq(mToken.balanceOf(projectSide), 2000);

        // buyer 是否收到 nft
        console.log("mNFT.ownerOf(1)", mNFT.ownerOf(1));
        assertEq(mNFT.ownerOf(1), buyer);

    }
}
