// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
contract FakeBond is ERC20 {
    constructor(uint256 initialSupply) ERC20("Fake Bond", "FBD")  {
        _mint(msg.sender, initialSupply);
    }
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
}
