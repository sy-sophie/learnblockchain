// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract BankLinkedStorage is Test {
    mapping(address => uint) public deposits;

    mapping(address => address) public ranking;

    address private constant GUARD = address(0);

    event Deposit(address indexed user, uint amount);
    constructor() {
        ranking[GUARD] == GUARD;
    }
    uint256 public count;

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        address user = msg.sender;
        uint newAmount = deposits[user] + msg.value;

        deposits[user] = newAmount;

        updateLeaderboard(user, newAmount);

        emit Deposit(user, msg.value);
    }
    function updateLeaderboard(address user, uint newBalance) public {
        if (ranking[user] == address(0)) { // user's first deposit
            address candidate = GUARD;
            while (ranking[candidate] != GUARD && deposits[ranking[candidate]] >= newBalance) { //iterate： find the position where the user should be inserted
                candidate = ranking[candidate];
            }

            ranking[user] = ranking[candidate];
            ranking[candidate] = user; // ranked after the candidate
            count++;
        } else {
            address oldCandidate = _findPrevDepositor(user); // the user already exists
            ranking[oldCandidate] = ranking[user];

            address newCandidate = GUARD;
            while (ranking[newCandidate] != GUARD && deposits[ranking[newCandidate]] >= newBalance) {
                newCandidate = ranking[newCandidate];
            }

            ranking[user] = ranking[newCandidate];
            ranking[newCandidate] = user;
        }
    }
    function _findPrevDepositor(address user) private view returns (address) {
        address current = GUARD;
        while (ranking[current] != user) {
            current = ranking[current];
        }
        return current;
    }

    function getTopUsers() external view returns (address[10] memory) {
        address[10] memory topUsers;
        address current = ranking[GUARD];

        for (uint256 i = 0; i < 10 && current != GUARD; ++i) {
            topUsers[i] = current;
            current = ranking[current];
        }

        return topUsers;
    }

    function getDeposit(address user) external view returns (uint) {
        return deposits[user];
    }

    function getRanking(address user) external view returns (address) {
        return ranking[user];
    }

    function getNextInRanking(address user) external view returns (address) {
        return ranking[user];
    }

}

