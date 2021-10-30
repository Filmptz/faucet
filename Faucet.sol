pragma solidity ^0.5.17;

import "./Whitelist.sol";
import "./openzeppelin/SafeMath.sol";
import "./openzeppelin/SafeERC20.sol";
import "./interfaces/IERC20.sol";

contract Faucet is Whitelist {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private tokenAmount;
    uint256 private waitTime;
    uint256 internal constant WEI_PRECISION = 10**18;
    
    IERC20 public usdt;
    IERC20 public busd; 

    constructor() public {
        tokenAmount = 1000;
        waitTime = 1 minutes;
    }
    
    event FaucetTransfer(address _to, uint256 value, uint256 timestamp);
    
    /* Map last access time for each token */
    mapping(address => mapping(string => uint256)) lastAccessTime; 
    
    modifier avoidZeroAddress(address _address) {
        require(_address != address(0), "recipient address cound not be 0x0");
        _;
    }

}