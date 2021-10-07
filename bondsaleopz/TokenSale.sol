// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

contract TokenSale is Context, ReentrancyGuard{
    using SafeERC20 for IERC20;
     // The token being sold
    IERC20 private token;
    // Address where funds are collected
    address payable private wallet;
    
    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint private rate;
    
    // Amount of wei received
    //this is the summation of weis the contract we have received for selling the tokens 
    uint private weiReceived;
    
    /**
     * Event for token purchase logging
     * @param _purchaser who paid for the tokens
     * @param _beneficiary who got the tokens
     * @param _value weis paid for purchase
     * @param _amount amount of tokens purchased
     */
     
    event TokensPurchased(address indexed _purchaser, address indexed _beneficiary, uint _value, uint _amount);
     /**
     * @param _rate Number of token units a buyer gets per wei
     * @dev The rate is the conversion between wei and the smallest and indivisible
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
     * @param _wallet Address where collected funds will be forwarded to
     * @param _token Address of the token being sold
     */
    constructor (uint _rate, address payable _wallet, IERC20 _token) {
        require(_rate > 0, "Sale: rate is 0");
        require(_wallet != address(0), "Sale: wallet is the zero address");
        require(address(_token) != address(0), "Sale: token is the zero address");

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }
    /**
     * @return the token being sold.
     */
    function getToken() public view returns (IERC20) {
        return token;
    }
     /**
     * @return the address where funds are collected.
     */
    function getWallet() public view returns (address payable) {
        return wallet;
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function getRate() public view returns (uint) {
        return rate;
    }
    
     /**
     * @return the amount of wei received.
     */
    function getWeiReceived() public view returns (uint) {
        return weiReceived;
    }
    /**
     * 
     * @param _beneficiary Recipient of the token purchase
     */
    //function buyTokens(address _beneficiary) public payable {
    function buyTokens(address _beneficiary) public nonReentrant payable {    
        uint weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint tokens = _getTokenAmount(weiAmount);

        // update state
        weiReceived = weiReceived + weiAmount;

        _processPurchase(_beneficiary, tokens);
        
        emit TokensPurchased(msg.sender, _beneficiary, weiAmount, tokens);

        _updatePurchasingState(_beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }
    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint _weiAmount) internal view virtual {
        require(_beneficiary != address(0), "TokenSale: beneficiary is the zero address");
        require(_weiAmount != 0, "TokenSale: weiAmount is 0");
    }
    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address _beneficiary, uint _weiAmount) internal view virtual {
        
    }
     /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint _tokenAmount) internal virtual {
        //token.transferFrom(wallet, _beneficiary, _tokenAmount);
        token.safeTransferFrom(wallet, _beneficiary, _tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint _tokenAmount) internal virtual {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions,
     * etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address _beneficiary, uint _weiAmount) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount) internal view virtual returns (uint256) {
        return _weiAmount * rate;
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
     
    receive() external payable {
        buyTokens(msg.sender );
    }
    
} 
