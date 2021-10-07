// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;
import "./Ownable.sol";
import "./ERC20Interface.sol";

// ----------------------------------------------------------------------------------------------
// Based-on Sample fixed supply token contract
// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
// ---------------------------------------------------------------------------------------------

contract FixedSupplyToken is ERC20Interface, Ownable {
    string private tokenSymbol;
    string private tokenName;
    uint8 private  tokenDecimals;
    uint256 private tokenTotalSupply;
    
    
    // Balances for each account
    mapping (address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    
    // Constructor
    constructor(string memory _name, string memory _symbol, uint _totalSupply, uint8 _decimals) {
        tokenName = _name;
        tokenSymbol = _symbol;
        tokenDecimals = _decimals;
        //tokenTotalSupply = _totalSupply * (10 ** _decimals);
        tokenTotalSupply = _totalSupply;
        balances[owner] = tokenTotalSupply;
    }
    
    
    function name() public view override returns (string memory) {
        return tokenName;
    }
    function symbol() public view override returns (string memory) {
        return tokenSymbol;
    }
    
    function decimals() public view override returns (uint8) {
        return tokenDecimals;
    }
    function totalSupply() public view override returns (uint256) {
        return tokenTotalSupply;
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) public view override returns (uint256 _balance) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public override returns (bool _success) {
        require(msg.sender != _to, "cannot transfer to yourself");
        require(balances[msg.sender] >= _amount, "you don't have enough tokens");
        balances[msg.sender] = balances[msg.sender] - _amount;
        balances[_to] = balances[_to] + _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    
    function transferFrom(
    address _from,
    address _to,
    uint256 _amount
    ) public override returns (bool success) {
        require(_from != _to, "cannot transfer to the allowance address");
        require(allowed[_from][msg.sender] >= _amount, "you do not have enough Approval tokens");
        balances[_from] = balances[_from] - _amount;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _amount;
        balances[_to] = balances[_to] + _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }


    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public override returns (bool _success) {
        require(balances[msg.sender] >= _amount, "The approval amount exceeds your balance");
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint _remaining) {
        return allowed[_owner][_spender];
    }
}