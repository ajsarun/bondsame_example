// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;
contract Ownable {
    address public owner;

    modifier onlyowner() {
        require (msg.sender == owner, "You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}