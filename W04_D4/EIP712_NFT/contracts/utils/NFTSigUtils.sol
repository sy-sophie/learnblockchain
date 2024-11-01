// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../src/RenftMarket.sol";


contract NFTSigUtils {
    bytes32 private DOMAIN_SEPARATOR;

    bytes32 public constant PERMIT_TYPEHASH = keccak256( "Permit(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)");
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }


//    struct RentoutOrder {
//        address maker; // 出租方地址
//        address nft_ca; // NFT合约地址
//        uint256 token_id; // NFT tokenId
//        uint256 daily_rent; // 每日租金
//        uint256 max_rental_duration; // 最大租赁时长
//        uint256 min_collateral; // 最小抵押
//        uint256 list_endtime; // 挂单结束时间
//    }

    function getStructHash(RentoutOrder memory _permit) public pure returns (bytes32){
        return keccak256( // 使用 keccak256 对结构体进行编码并返回哈希值
            abi.encode(
                STORAGE_TYPEHASH,
                _permit.maker,
                _permit.nft_ca,
                _permit.token_id,
                _permit.daily_rent,
                _permit.max_rental_duration,
                _permit.min_collateral,
                _permit.list_endtime
            )
        );
    }
    function getTypedDataHash(RentoutOrder memory _permit) public returns (bytes32){
        return
            keccak256( // 使用 keccak256 对域分隔符和结构体哈希值进行编码并返回哈希值
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                getStructHash(_permit)
            )
        );
    }
}
