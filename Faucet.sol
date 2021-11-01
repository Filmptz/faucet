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
    
    IERC20 private _usdt;
    IERC20 private _busd; 

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
    
    function allowedToWithdraw(address _address, string memory _tokenSymbol) internal view returns (bool) {
        if(lastAccessTime[_address][_tokenSymbol] == 0) {
            return true;
        } else if(block.timestamp >= lastAccessTime[_address][_tokenSymbol]) {
            return true;
        }
        return false;
    }
    
    function updateTokenAmount(uint256 _tokenAmount) public onlyAdmin{
        tokenAmount = _tokenAmount;
    }
    
    function setBUSDAddress(address _busdAddr) public onlyAdmin avoidZeroAddress(_busdAddr){
        _busd = IERC20(_busdAddr);
    }
    
    function getBUSDBalance() public view returns (uint256){
        return _busd.balanceOf(address(this));
    }
    
    function faucetSendBUSD(address payable _to) public avoidZeroAddress(_to) payable{
        require(allowedToWithdraw(msg.sender,'busd'));
        require(getBUSDBalance() >= tokenAmount,"BUSD balances are not enough!!");
        
        _busd.safeTransfer(_to, tokenAmount.mul(WEI_PRECISION));
        lastAccessTime[msg.sender]['busd'] = block.timestamp + waitTime;

        emit FaucetTransfer(_to, tokenAmount, block.timestamp);
    }
}