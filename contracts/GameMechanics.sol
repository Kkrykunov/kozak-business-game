// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IResourceNFT1155 {
    function mint(address to, uint256 id, uint256 amount) external;
    function burn(address from, uint256 id, uint256 amount) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function IRON() external pure returns (uint256);
    function WOOD() external pure returns (uint256);
    function LEATHER() external pure returns (uint256);
    function GOLD() external pure returns (uint256);
    function DIAMOND() external pure returns (uint256);
}

interface IItemNFT721 {
    enum ItemType { KOZAK_SWORD, ELDER_STAFF, KHARAKTERNIK_ARMOR, BATTLE_BRACELET }
    function mint(address to, ItemType itemType) external returns (uint256);
}

/**
 * @title GameMechanics
 * @dev Контракт для механік пошуку ресурсів і крафтингу предметів
 */
contract GameMechanics {
    IResourceNFT1155 public resourceContract;
    IItemNFT721 public itemContract;
    
    // Час останнього пошуку для кожного гравця
    mapping(address => uint256) public lastSearchTime;
    
    // Необхідні ресурси для кожного типу предмета
    struct ResourceRequirement {
        uint256 resourceId;
        uint256 amount;
    }
    
    // Мапа типу предмета до списку необхідних ресурсів
    mapping(IItemNFT721.ItemType => ResourceRequirement[]) public craftingRequirements;
    
    /**
     * @dev Конструктор контракту GameMechanics
     * @param _resourceContract Адреса контракту ResourceNFT1155
     * @param _itemContract Адреса контракту ItemNFT721
     */
    constructor(address _resourceContract, address _itemContract) {
        resourceContract = IResourceNFT1155(_resourceContract);
        itemContract = IItemNFT721(_itemContract);
        
        // Налаштування рецептів крафтингу
        
        // Шабля козака
        _setupCraftingRequirement(
            IItemNFT721.ItemType.KOZAK_SWORD,
            resourceContract.IRON(),
            3
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.KOZAK_SWORD,
            resourceContract.WOOD(),
            1
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.KOZAK_SWORD,
            resourceContract.LEATHER(),
            1
        );
        
        // Посох старійшини
        _setupCraftingRequirement(
            IItemNFT721.ItemType.ELDER_STAFF,
            resourceContract.WOOD(),
            2
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.ELDER_STAFF,
            resourceContract.GOLD(),
            1
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.ELDER_STAFF,
            resourceContract.DIAMOND(),
            1
        );
        
        // Броня характерника
        _setupCraftingRequirement(
            IItemNFT721.ItemType.KHARAKTERNIK_ARMOR,
            resourceContract.LEATHER(),
            4
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.KHARAKTERNIK_ARMOR,
            resourceContract.IRON(),
            2
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.KHARAKTERNIK_ARMOR,
            resourceContract.GOLD(),
            1
        );
        
        // Бойовий браслет
        _setupCraftingRequirement(
            IItemNFT721.ItemType.BATTLE_BRACELET,
            resourceContract.IRON(),
            4
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.BATTLE_BRACELET,
            resourceContract.GOLD(),
            2
        );
        _setupCraftingRequirement(
            IItemNFT721.ItemType.BATTLE_BRACELET,
            resourceContract.DIAMOND(),
            2
        );
    }
    
    /**
     * @dev Додає вимогу до рецепту крафтингу
     * @param itemType Тип предмета
     * @param resourceId ID ресурсу
     * @param amount Кількість ресурсу
     */
    function _setupCraftingRequirement(
        IItemNFT721.ItemType itemType,
        uint256 resourceId,
        uint256 amount
    ) private {
        craftingRequirements[itemType].push(ResourceRequirement({
            resourceId: resourceId,
            amount: amount
        }));
    }
    
    /**
     * @dev Випадковий пошук ресурсів
     */
    function searchResources() external {
        require(block.timestamp >= lastSearchTime[msg.sender] + 60, "You must wait 60 seconds between searches");
        
        lastSearchTime[msg.sender] = block.timestamp;
        
        // Генерація 3 випадкових ресурсів
        uint256 resource1 = _getRandomResource(block.timestamp, msg.sender, 0);
        uint256 resource2 = _getRandomResource(block.timestamp, msg.sender, 1);
        uint256 resource3 = _getRandomResource(block.timestamp, msg.sender, 2);
        
        // Мінтимо ресурси гравцю
        resourceContract.mint(msg.sender, resource1, 1);
        resourceContract.mint(msg.sender, resource2, 1);
        resourceContract.mint(msg.sender, resource3, 1);
    }
    
    /**
     * @dev Генерація випадкового ресурсу
     * @param seed Базове значення для генерації
     * @param player Адреса гравця
     * @param nonce Додатковий параметр для генерації
     * @return ID випадкового ресурсу
     */
    function _getRandomResource(uint256 seed, address player, uint256 nonce) private view returns (uint256) {
        uint256 randomValue = uint256(keccak256(abi.encodePacked(
            seed, player, nonce, blockhash(block.number - 1)
        ))) % 6; // 6 типів ресурсів
        
        return randomValue;
    }
    
    /**
     * @dev Крафт предмета
     * @param itemType Тип предмета, який необхідно створити
     * @return ID створеного предмета
     */
    function craftItem(IItemNFT721.ItemType itemType) external returns (uint256) {
        ResourceRequirement[] memory requirements = craftingRequirements[itemType];
        
        // Перевіряємо, чи має гравець необхідні ресурси
        for (uint256 i = 0; i < requirements.length; i++) {
            require(
                resourceContract.balanceOf(msg.sender, requirements[i].resourceId) >= requirements[i].amount,
                "Not enough resources"
            );
        }
        
        // Спалюємо ресурси
        for (uint256 i = 0; i < requirements.length; i++) {
            resourceContract.burn(
                msg.sender, 
                requirements[i].resourceId, 
                requirements[i].amount
            );
        }
        
        // Створюємо предмет
        return itemContract.mint(msg.sender, itemType);
    }
}