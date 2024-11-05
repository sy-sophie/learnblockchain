// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MyWalletNew {
    string public name;
    mapping(address => bool) private approved;
    address public owner;

    modifier auth {
        require(msg.sender == _getOwner(), "Not authorized");
        _;
    }

    function _getOwner() private view returns (address ownerAddr) {
        assembly {
            ownerAddr := sload(2)
        }
    }

    function _setOwner(address _newOwner) private {
        assembly {
            sstore(2, _newOwner)  // 将`owner`地址写入槽位0
        }
    }
    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }

    function transferOwernship(address _addr) external {
        require(_addr != address(0), "New owner is the zero address");
        _setOwner(_addr);
    }
}

