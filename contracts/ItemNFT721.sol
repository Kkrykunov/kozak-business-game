// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ItemNFT721 is ERC721Enumerable, Ownable {
   enum ItemType { KOZAK_SWORD, ELDER_STAFF, KHARAKTERNIK_ARMOR, BATTLE_BRACELET }
   
   struct Item {
       ItemType itemType;
       uint256 createdAt;
   }
   
   mapping(uint256 => Item) public items;
   mapping(address => bool) public authorizedContracts;
   
   constructor(address initialOwner) 
       ERC721("KozakItems", "KZKI") 
       Ownable(initialOwner) 
   {}
   
   function addAuthorizedContract(address contractAddress) external onlyOwner {
       authorizedContracts[contractAddress] = true;
   }
   
   function removeAuthorizedContract(address contractAddress) external onlyOwner {
       authorizedContracts[contractAddress] = false;
   }
   
   function mint(address to, ItemType itemType) external returns (uint256) {
       require(authorizedContracts[msg.sender], "Not authorized to mint");
       
       uint256 tokenId = totalSupply() + 1;
       
       items[tokenId] = Item({
           itemType: itemType,
           createdAt: block.timestamp
       });
       
       _mint(to, tokenId);
       
       return tokenId;
   }
   
   function burn(uint256 tokenId) external {
       require(authorizedContracts[msg.sender], "Not authorized to burn");
       require(_isAuthorized(_ownerOf(tokenId), msg.sender, tokenId), "Not authorized");
       
       delete items[tokenId];
       _burn(tokenId);
   }
   
   function getItemType(uint256 tokenId) external view returns (ItemType) {
       return items[tokenId].itemType;
   }
}