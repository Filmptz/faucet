pragma solidity ^0.5.17;

import "./Whitelist.sol";
import "./openzeppelin/SafeMath.sol";
import "./openzeppelin/SafeERC20.sol";
import "./interfaces/IERC20.sol";

contract Faucet is Whitelist {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct FaucetContract {
        uint256 tokenAmount;
        uint256 waitTime;
        IERC20 usdt;
        IERC20 busd;
    }
    FaucetContract faucetInfo;

    uint256 internal constant WEI_PRECISION = 10**18;

    constructor() public {
        faucetInfo.tokenAmount = 1000;
        faucetInfo.waitTime = 1 minutes;
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

    function setTokenAmount(uint256 _amount) public onlyAdmin {
        faucetInfo.tokenAmount = _amount;
    }

    function setWatiTime(uint256 _waitTiem) public onlyAdmin {
        faucetInfo.waitTime = _waitTiem;
    }

    function setBUSDAddress(address _address)
        public
        onlyAdmin
        avoidZeroAddress(_address)
    {
        faucetInfo.busd = IERC20(_address);
    }

    function setUSDTAddress(address _address)
        public
        onlyAdmin
        avoidZeroAddress(_address)
    {
        faucetInfo.usdt = IERC20(_address);
    }

    function getBalance() public view returns (uint256 usdt, uint256 busd) {
        return (
            faucetInfo.usdt.balanceOf(address(this)),
            faucetInfo.busd.balanceOf(address(this))
        );
    }

    function faucetSendBUSD(address payable _to)
        public
        payable
        avoidZeroAddress(_to)
    {
        (uint256 usdtBalance, uint256 busdBalance) = getBalance();
        require(allowedToWithdraw(_to, "busd"), "withdrawal cooldown");
        require(busdBalance > faucetInfo.tokenAmount, "insufficient USDT");

        faucetInfo.busd.safeTransfer(
            _to,
            (faucetInfo.tokenAmount).mul(WEI_PRECISION)
        );
        lastAccessTime[_to]["busd"] = block.timestamp + faucetInfo.waitTime;

        emit FaucetTransfer(_to, faucetInfo.tokenAmount, block.timestamp);
    }

    function faucetSendUSDT(address payable _to)
        public
        payable
        avoidZeroAddress(_to)
    {
        (uint256 usdtBalance, uint256 busdBalance) = getBalance();
        require(allowedToWithdraw(_to, "usdt"), "withdrawal cooldown");
        require(usdtBalance > faucetInfo.tokenAmount, "insufficient USDT");

        faucetInfo.usdt.safeTransfer(
            _to,
            (faucetInfo.tokenAmount).mul(WEI_PRECISION)
        );
        lastAccessTime[_to]["usdt"] = block.timestamp + faucetInfo.waitTime;

        emit FaucetTransfer(_to, faucetInfo.tokenAmount, block.timestamp);
    }
}
