pragma solidity ^0.5.17;

import "./openzeppelin/Ownable.sol";

contract Whitelist is Ownable {

    event AddAdmin(address newAdmin);
    event RemoveAdmin(address admin);

    /* map admin address */
    mapping(address => bool) private _whitelist;
    address[] private _adminList;
    address private _owner;
    
    /*Init Owner is admin*/
    constructor () internal {
        _owner = owner();
        _whitelist[_owner] = true;
        _adminList.push(_owner);
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Admin unauthorized");
        _;
    }

    function getAdmin() public view returns (address[] memory){
        return _adminList;
    }

    function isAdmin(address _admin) public view returns (bool){
        return _whitelist[_admin];
    }

    function addAdmin(address _admin) public onlyOwner returns (bool){
        require(!_whitelist[_admin], "Admin address is already exist");
        _whitelist[_admin] = true;

        _adminList.push(_admin);
        emit AddAdmin(_admin);
    }

    function removeAdmin(address _admin) public onlyOwner returns (bool){
        require(_whitelist[_admin], "Not a contract admin");
        delete _whitelist[_admin];

        for(uint256 i; i<_adminList.length; i++){
            if(_adminList[i] == _admin) {
                _adminList[i] = _adminList[_adminList.length - 1]; // move to last element
                _adminList.pop(); // remove last element
            }
        }

        emit RemoveAdmin(_admin);
    }
    
}