pragma solidity ^0.4.15;

import './helpers/BasicToken.sol';
import './lib/safeMath.sol';

contract HadeToken is BasicToken {

using SafeMath for uint256;

//token attributes

string public name = "HADE";                 //name of the token

string public symbol = "HADE";                      // symbol of the token

uint8 public decimals = 18;                        // decimals

uint256 public totalSupply = 1000000000 * 10**18;  // total supply of Hade Tokens 

uint256 public totalAllocatedTokens;                // variable to regulate the funds allocation

uint256 public tokensForCrowdsale;                  // Tokens for ICO (crowdsale) 

uint256 public tokensForReward;                     // funds allocated to rewardContract


// addresses

address public founderMultiSigAddress;              // multi sign address of founders which hold 

address public crowdsaleAddress;                    // address of crowdsale contract


//events
event ChangeFoundersWalletAddress(uint256  _blockTimeStamp, address indexed _foundersWalletAddress);
event RewardTokenTransferred(uint256  _blockTimeStamp , address _to , uint256 _value);


///////////////////////////////////////// CONSTRUCTOR //////////////////////////////////////////////////

   function HadeToken (address _founderMultiSigAddress, address _crowdsaleContract) {
    
    founderMultiSigAddress = _founderMultiSigAddress;
    crowdsaleAddress = _crowdsaleContract;
    
    tokensForReward = 50 * 10 ** 25;                       // 50 % allocation of totalSupply    
    tokensForCrowdsale = 50 * 10 ** 25;                    // 50 % allocation of totalSupply

    balances[crowdsaleAddress] = tokensForCrowdsale;

  }

///////////////////////////////////////// MODIFIERS /////////////////////////////////////////////////

  modifier onlyCrowdsale() {
    require(msg.sender == crowdsaleAddress);
    _;
  }

  modifier nonZeroAddress(address _to) {
    require(_to != 0x0);
    _;
  }

  modifier onlyFounders() {
    require(msg.sender == founderMultiSigAddress);
    _;
  }

////////////////////////////////////////// FUNCTIONS //////////////////////////////////////////////


  /**
      @dev function used to change the supply of token in the market , it only called by crowdsale
      @param _amount amount is the token quantity added in token supply
  
   */


  function changeTotalSupply(uint256 _amount) onlyCrowdsale {
    totalAllocatedTokens += _amount;
  }


  /**
      @dev function is used to change the founder wallet address called only by founder
      @param _newFounderMultiSigAddress new address of founder
  
   */
           
  function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) 
  onlyFounders 
  nonZeroAddress(_newFounderMultiSigAddress) 
  {
    founderMultiSigAddress = _newFounderMultiSigAddress;
    ChangeFoundersWalletAddress(now, founderMultiSigAddress);
  }


  /**
      @dev function is used to transfer the reward token called only by the founder
      @param _to it is the address whom the reward token get transferred
      @param _value amount of reward token.
      @return bool 
  */


  function transferRewardToken(address _to, uint256 _value) onlyFounders returns (bool) {
    if (tokensForReward >= _value && balances[_to] + _value > balances[_to]) {
      tokensForReward -= _value;
      balances[_to] += _value;
      RewardTokenTransferred(now,_to,_value);
      return true;
    }
      return false;
  }


}