pragma solidity ^0.5.17;

import "./openzeppelin/Ownable.sol";

contract Whitelist is Ownable {

    event AddAdmin(address newAdmin);
    event RemoveAdmin(address admin);

    /* map admin address */
    mapping(address => bool) whitelist;
    address[] adminList;

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Admin unauthorized");
        _;
    }

    function getAdmin() public view returns (address[] memory){
        return adminList;
    }

    function isAdmin(address _admin) public view returns (bool){
        return whitelist[_admin];
    }

    function addAdmin(address _admin) public onlyOwner returns (bool){
        require(!whitelist[_admin], "Admin address is already exist");
        whitelist[_admin] = true;

        adminList.push(_admin);
        emit AddAdmin(_admin);
    }

    function removeAdmin(address _admin) public onlyOwner returns (bool){
        require(whitelist[_admin], "Not a contract admin");
        delete whitelist[_admin];

        for(uint256 i; i<adminList.length; i++){
            if(adminList[i] == _admin) {
                adminList[i] = adminList[adminList.length - 1]; // move to last element
                adminList.pop(); // remove last element
            }
        }

        emit RemoveAdmin(_admin);
    }
    
}