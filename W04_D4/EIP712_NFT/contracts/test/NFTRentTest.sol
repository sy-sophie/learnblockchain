// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import "../src/RenftMarket.sol";
import "../src/NFTFactory.sol";
import "../utils/NFTSigUtils.sol";

contract NFTRentTest is Test {
    NFTSigUtils internal nftSigUtils;
    RenftMarket public market;
    NFTFactory public factory;
    S2NFT public nft1;
    S2NFT public nft2;

    uint256 internal lessor1PrivateKey = 0x123;
    address lessor1 = vm.addr(lessor1PrivateKey);  // 出租方
    address lessor2 = vm.addr(2);  // 出租方
    address lessee1 = vm.addr(3);  // 租赁方
    address lessee2 = vm.addr(4);  // 租赁方


    function setUp() public {
        factory = new NFTFactory();
        market = new RenftMarket();

        nft1 = S2NFT(factory.deployNFT("NFT1", "NFT1", "ipfs://Qme5FFDdvkNWs3cN4w8vBkUoiGQcrbKVakWr624PUZEpz3", 2));
        nft2 = S2NFT(factory.deployNFT("NFT2", "NFT2", "ipfs://QmYZ98mPBKerciAjGjtJRwd6tjLyx17e3BJkhFvi4eimkT", 4));

        vm.startPrank(lessor1);
        nft1.freeMint(2);
        nft1.approve(address(market), 1); // TODO 授权 NFT 合约
        vm.stopPrank();

        vm.startPrank(lessor2);
        nft2.freeMint(3);
        vm.stopPrank();

        vm.deal(lessee1, 100 ether);  // 给租赁方1发送100以太币
        vm.deal(lessee2, 150 ether);  // 给租赁方2发送150以太币

    }


    function testSuccessfulBorrow() public {
        nftSigUtils = new NFTSigUtils(market.DOMAIN_SEPARATOR());
        // 出租方：填写租赁信息
        vm.startPrank(lessor1);
        RentoutOrder memory permit = RentoutOrder({
            maker: lessor1,
            nft_ca: address(nft1),
            token_id: 1,
            daily_rent: 0.01 ether,
            max_rental_duration: 7 days,
            min_collateral: 0.05 ether,
            list_endtime: block.timestamp + 1 days
        });
        bytes32 typedDataHash = nftSigUtils.getTypedDataHash(permit);

        vm.startPrank(lessor1);
        // 签名订单 = 填写租赁信息 + 出租方私钥
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(lessor1PrivateKey, typedDataHash);
        bytes memory signature = abi.encodePacked(r, s, v); // 将 r, s, v 拼接成 bytes

        vm.stopPrank();

        // 租赁方：发送足够的以太币
        vm.startPrank(lessee1);
        market.borrow{value: 0.05 ether}(permit, signature);
        vm.stopPrank();

        // 检查 lessee1 是否收到了 NFT
        address currentOwner = nft1.ownerOf(1);
        require(currentOwner == lessee1, "lessee1 did not receive the NFT");

        uint256 lessor1BalanceAfter = address(lessor1).balance;
        require(lessor1BalanceAfter > 0, "lessor1 did not receive the money");
    }
    function testSuccessfulCancelOrder() public {
        nftSigUtils = new NFTSigUtils(market.DOMAIN_SEPARATOR());
        vm.startPrank(lessor1);
        RentoutOrder memory permit = RentoutOrder({
            maker: lessor1,
            nft_ca: address(nft1),
            token_id: 1,
            daily_rent: 0.01 ether,
            max_rental_duration: 7 days,
            min_collateral: 0.05 ether,
            list_endtime: block.timestamp + 1 days
        });
        bytes32 typedDataHash = nftSigUtils.getTypedDataHash(permit);

        vm.startPrank(lessor1);
        // 签名订单 = 填写租赁信息 + 出租方私钥
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(lessor1PrivateKey, typedDataHash);
        bytes memory signature = abi.encodePacked(r, s, v); // 将 r, s, v 拼接成 bytes

        bool isCanceled = market.canceledOrders(bytes32(signature));
        require(isCanceled == true, "Order was not canceled successfully");
        vm.stopPrank();
    }
}
