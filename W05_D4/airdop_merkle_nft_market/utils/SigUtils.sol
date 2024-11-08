// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR; // 内部存储域分隔符
    }

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    struct Permit {
        address owner;   // 许可的拥有者地址
        address spender; // 允许支出的地址
        uint256 value;   // 允许支出的数量
        uint256 nonce;   // 用于防止重放攻击的随机数
        uint256 deadline;// 许可的有效截止时间
    }

    // computes the hash of a permit
    function getStructHash(Permit memory _permit) public pure returns (bytes32){
        return keccak256( // 使用 keccak256 对结构体进行编码并返回哈希值
            abi.encode(
                PERMIT_TYPEHASH,
                _permit.owner,
                _permit.spender,
                _permit.value,
                _permit.nonce,
                _permit.deadline
            )
        );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
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
