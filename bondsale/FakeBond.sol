// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;
import "./FixedSupplyToken.sol";

contract FakeBond is FixedSupplyToken {
    constructor (uint _initialSupply) FixedSupplyToken("Fake Bonds", "FBD", _initialSupply, 0) {
        
    }
}