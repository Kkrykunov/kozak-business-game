// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ResourceNFT1155 is ERC1155, Ownable {
    uint256 public constant WOOD = 0;
    uint256 public constant IRON = 1;
    uint256 public constant GOLD = 2;
    uint256 public constant LEATHER = 3;
    uint256 public constant STONE = 4;
    uint256 public constant DIAMOND = 5;
    
    mapping(address => bool) public authorizedContracts;
    
    constructor(address initialOwner) 
        ERC1155("https://kozak-game.example/resources/{id}.json") 
        Ownable(initialOwner) 
    {}
    
    function addAuthorizedContract(address contractAddress) external onlyOwner {
        authorizedContracts[contractAddress] = true;
    }
    
    function removeAuthorizedContract(address contractAddress) external onlyOwner {
        authorizedContracts[contractAddress] = false;
    }
    
    function mint(address to, uint256 id, uint256 amount) external {
        require(authorizedContracts[msg.sender], "Not authorized to mint");
        _mint(to, id, amount, "");
    }
    
    function burn(address from, uint256 id, uint256 amount) external {
        require(authorizedContracts[msg.sender], "Not authorized to burn");
        _burn(from, id, amount);
    }
    
    function isValidResourceId(uint256 id) public pure returns (bool) {
        return id <= DIAMOND;
    }
}