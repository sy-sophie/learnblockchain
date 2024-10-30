// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/erc20_token.sol";
import "../src/erc721_nft.sol";
import "../src/NFTMarket.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        MyToken myToken = new MyToken();
        MyNFT myNFT = new MyNFT();
        NFTMarket nftMarket = new NFTMarket();

        vm.stopBroadcast();
    }
}
