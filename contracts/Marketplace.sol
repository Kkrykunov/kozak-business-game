// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function mint(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IResourceNFT1155 {
    function mint(address to, uint256 id, uint256 amount) external;
    function burn(address from, uint256 id, uint256 amount) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

interface IItemNFT721 {
    enum ItemType { KOZAK_SWORD, ELDER_STAFF, KHARAKTERNIK_ARMOR, BATTLE_BRACELET }
    function mint(address to, ItemType itemType) external returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

/**
 * @title Marketplace
 * @dev Контракт для торгівлі NFT предметами та ресурсами
 */
contract Marketplace is Ownable {
    IERC20 public magicToken;
    IResourceNFT1155 public resourceContract;
    IItemNFT721 public itemContract;
    
    uint256 public feePercentage = 2; // 2% комісія
    
    struct ResourceListing {
        address seller;
        uint256 resourceId;
        uint256 amount;
        uint256 price;
        bool active;
    }
    
    struct ItemListing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    
    mapping(uint256 => ResourceListing) public resourceListings;
    mapping(uint256 => ItemListing) public itemListings;
    
    uint256 public nextResourceListingId = 1;
    uint256 public nextItemListingId = 1;
    
    constructor(
        address initialOwner,
        address _magicToken,
        address _resourceContract,
        address _itemContract
    ) Ownable(initialOwner) {
        magicToken = IERC20(_magicToken);
        resourceContract = IResourceNFT1155(_resourceContract);
        itemContract = IItemNFT721(_itemContract);
    }
    
    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 10, "Fee percentage too high");
        feePercentage = _feePercentage;
    }
    
    function listResource(uint256 resourceId, uint256 amount, uint256 price) external returns (uint256) {
        require(amount > 0, "Amount must be greater than 0");
        require(price > 0, "Price must be greater than 0");
        require(
            resourceContract.balanceOf(msg.sender, resourceId) >= amount,
            "Not enough resources"
        );
        
        uint256 listingId = nextResourceListingId++;
        
        resourceListings[listingId] = ResourceListing({
            seller: msg.sender,
            resourceId: resourceId,
            amount: amount,
            price: price,
            active: true
        });
        
        resourceContract.safeTransferFrom(msg.sender, address(this), resourceId, amount, "");
        
        return listingId;
    }
    
    function listItem(uint256 tokenId, uint256 price) external returns (uint256) {
        require(price > 0, "Price must be greater than 0");
        require(itemContract.ownerOf(tokenId) == msg.sender, "Not the owner");
        
        uint256 listingId = nextItemListingId++;
        
        itemListings[listingId] = ItemListing({
            seller: msg.sender,
            tokenId: tokenId,
            price: price,
            active: true
        });
        
        itemContract.transferFrom(msg.sender, address(this), tokenId);
        
        return listingId;
    }
    
    function buyResource(uint256 listingId) external {
        ResourceListing storage listing = resourceListings[listingId];
        
        require(listing.active, "Listing not active");
        require(
            magicToken.balanceOf(msg.sender) >= listing.price,
            "Not enough tokens"
        );
        
        listing.active = false;
        
        uint256 fee = (listing.price * feePercentage) / 100;
        uint256 sellerAmount = listing.price - fee;
        
        magicToken.transferFrom(msg.sender, listing.seller, sellerAmount);
        magicToken.transferFrom(msg.sender, owner(), fee);
        
        resourceContract.safeTransferFrom(address(this), msg.sender, listing.resourceId, listing.amount, "");
    }
    
    function buyItem(uint256 listingId) external {
        ItemListing storage listing = itemListings[listingId];
        
        require(listing.active, "Listing not active");
        require(
            magicToken.balanceOf(msg.sender) >= listing.price,
            "Not enough tokens"
        );
        
        listing.active = false;
        
        uint256 fee = (listing.price * feePercentage) / 100;
        uint256 sellerAmount = listing.price - fee;
        
        magicToken.transferFrom(msg.sender, listing.seller, sellerAmount);
        magicToken.transferFrom(msg.sender, owner(), fee);
        
        itemContract.transferFrom(address(this), msg.sender, listing.tokenId);
    }
    
    function cancelResourceListing(uint256 listingId) external {
        ResourceListing storage listing = resourceListings[listingId];
        
        require(listing.active, "Listing not active");
        require(listing.seller == msg.sender, "Not the seller");
        
        listing.active = false;
        
        resourceContract.safeTransferFrom(address(this), msg.sender, listing.resourceId, listing.amount, "");
    }
    
    function cancelItemListing(uint256 listingId) external {
        ItemListing storage listing = itemListings[listingId];
        
        require(listing.active, "Listing not active");
        require(listing.seller == msg.sender, "Not the seller");
        
        listing.active = false;
        
        itemContract.transferFrom(address(this), msg.sender, listing.tokenId);
    }
    
    function distributeTokens(address to, uint256 amount) external onlyOwner {
        magicToken.mint(to, amount);
    }
}