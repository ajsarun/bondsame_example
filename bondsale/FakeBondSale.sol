// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;
import "./TokenSale.sol";
contract FakeBondSale is TokenSale {
    constructor(uint _rate, address payable _wallet, ERC20Interface _token) TokenSale(_rate, _wallet, _token) {
      
    }
    function _preValidatePurchase(address _beneficiary, uint _weiAmount) internal view override {
        address wallet = getWallet();
        require(wallet != _beneficiary, "Owner cannot buy token");
        super._preValidatePurchase(_beneficiary,_weiAmount);
    }
}