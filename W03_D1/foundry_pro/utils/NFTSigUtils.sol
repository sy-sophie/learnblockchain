// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract NFTSigUtils {
    bytes32 private DOMAIN_SEPARATOR;

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address buyer,uint256 tokenId,uint256 deadline)");
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");

    constructor(bytes32 _DOMAIN_SEPARATOR) {
//        DOMAIN_SEPARATOR = keccak256(abi.encode(
//            PERMIT_TYPEHASH, // type hash
//            keccak256(bytes("EIP712Storage")), // name
//            keccak256(bytes("1")), // version
//            block.chainid, // chain id
//            address(this) // contract address
//        ));
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }


    struct Permit {
        address buyer;   // 许可的拥有者地址
        uint256 tokenId;   // NFT的token
        uint256 deadline;// 许可的有效截止时间
    }

    function getStructHash(Permit memory _permit) public pure returns (bytes32){
        return keccak256( // 使用 keccak256 对结构体进行编码并返回哈希值
            abi.encode(
                STORAGE_TYPEHASH,
                _permit.buyer,
                _permit.tokenId,
                _permit.deadline
            )
        );
    }
    // TODO view
    function getTypedDataHash(Permit memory _permit) public returns (bytes32){
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
