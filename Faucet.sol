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

  function allowedToWithdraw(address _address, string memory _tokenSymbol)
    internal
    view
    returns (bool)
  {
    if (lastAccessTime[_address][_tokenSymbol] == 0) {
      return true;
    } else if (block.timestamp >= lastAccessTime[_address][_tokenSymbol]) {
      return true;
    }
    return false;
  }

  function setUsdtAddress(address _address)
    public
    onlyAdmin
    avoidZeroAddress(_address)
  {
    usdt = IERC20(_address);
  }

  function setTokenAmount(uint256 _tokenAmount) private onlyAdmin {
    tokenAmount = _tokenAmount;
  }

  function setMaximumTokenAmount(uint256 _amount) public onlyAdmin {
    tokenAmount = _amount;
  }

  function setWatiTime(uint256 _waitTiem) public onlyAdmin {
    waitTime = _waitTiem;
  }

  function getUsdtBalance() public view returns (uint256) {
    return usdt.balanceOf(address(this));
  }

  function withdrawUsdt(uint256 _amount) public {
    require(allowedToWithdraw(_msgSender(), "usdt"), "withdrawal cooldown");
    require(getUsdtBalance() > _amount, "insufficient USDT");
    require(
      _amount <= tokenAmount,
      "withdrawal amount cannot exceed the maximum token amount"
    );

    usdt.safeTransfer(_msgSender(), _amount.mul(WEI_PRECISION));
    lastAccessTime[_msgSender()]["usdt"] = block.timestamp + waitTime;

    emit FaucetTransfer(_msgSender(), _amount, block.timestamp);
  }
}
