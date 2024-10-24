// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract NFTSigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR; // 内部存储域分隔符
    }

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address buyer,address projectOwner,uint256 tokenId,uint256 nonce,uint256 deadline)");

    struct Permit {
        address buyer;   // 许可的拥有者地址
        address projectOwner; // 项目方
        uint256 tokenId;   // NFT的token
        uint256 nonce;   // 用于防止重放攻击的随机数
        uint256 deadline;// 许可的有效截止时间
    }

    function getStructHash(Permit memory _permit) public pure returns (bytes32){
        return keccak256( // 使用 keccak256 对结构体进行编码并返回哈希值
            abi.encode(
                PERMIT_TYPEHASH,
                _permit.buyer,
                _permit.projectOwner,
                _permit.tokenId,
                _permit.nonce,
                _permit.deadline
            )
        );
    }
    function getTypedDataHash(Permit memory _permit) public view returns (bytes32){
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
