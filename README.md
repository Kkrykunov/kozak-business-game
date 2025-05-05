# Козацький Бізнес (Kozak Business Game)

Децентралізована блокчейн-гра з механіками NFT для тестового завдання WhiteBIT.

## Опис проекту

"Козацький Бізнес" - це блокчейн-гра, де гравці:
- 🌲 Шукають ресурси (ERC1155)
- ⚔️ Створюють унікальні предмети (ERC721)
- 💰 Торгують на маркетплейсі за MagicToken (ERC20)

## Архітектура контрактів

1. **ResourceNFT1155**: Контракт ресурсів гри (ERC1155)
2. **ItemNFT721**: Контракт унікальних предметів (ERC721)
3. **MagicToken**: Ігрова валюта (ERC20)
4. **GameMechanics**: Логіка пошуку ресурсів та крафтингу
5. **Marketplace**: Маркетплейс для торгівлі

## Адреси контрактів

### Sepolia Testnet:
- ResourceNFT1155: `0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D`
- ItemNFT721: `0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781`
- MagicToken: `0x223c1d0df523771D8125197617318f97Dd913C51`
- GameMechanics: `0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B`
- Marketplace: `0x499b2f76E073aAF4199B72A868992a3e29f79096`

## Встановлення і запуск

### Вимоги
- Node.js >= 18.0.0
- npm >= 8.0.0

### Встановлення
```bash
git clone <repository-url>
cd kozak-business-game
npm install