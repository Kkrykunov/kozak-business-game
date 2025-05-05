// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MagicToken is ERC20, Ownable {
    address public marketplaceAddress;
    
    constructor(address initialOwner) 
        ERC20("MagicToken", "MTK") 
        Ownable(initialOwner)
    {}
    
    function setMarketplaceAddress(address _marketplaceAddress) external onlyOwner {
        marketplaceAddress = _marketplaceAddress;
    }
    
    function mint(address to, uint256 amount) external {
        require(msg.sender == marketplaceAddress, "Only marketplace can mint tokens");
        _mint(to, amount);
    }
}