import { run } from "hardhat";

// Contract addresses from Sepolia deployment
const RESOURCE_NFT_ADDRESS = "0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D";
const ITEM_NFT_ADDRESS = "0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781";
const MAGIC_TOKEN_ADDRESS = "0x223c1d0df523771D8125197617318f97Dd913C51";
const GAME_MECHANICS_ADDRESS = "0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B";
const MARKETPLACE_ADDRESS = "0x499b2f76E073aAF4199B72A868992a3e29f79096";
const OWNER_ADDRESS = "0x156C82251E1f27Bcd5AF2bE86605438E5dCdCD24";

async function main() {
  console.log("Verifying contracts on Etherscan...");

  try {
    // Verify ResourceNFT1155
    console.log("Verifying ResourceNFT1155...");
    await run("verify:verify", {
      address: RESOURCE_NFT_ADDRESS,
      constructorArguments: [OWNER_ADDRESS],
      contract: "contracts/ResourceNFT1155.sol:ResourceNFT1155",
    });
    console.log("ResourceNFT1155 verified successfully");
  } catch (error) {
    console.error("Error verifying ResourceNFT1155:", error);
  }

  try {
    // Verify ItemNFT721
    console.log("Verifying ItemNFT721...");
    await run("verify:verify", {
      address: ITEM_NFT_ADDRESS,
      constructorArguments: [OWNER_ADDRESS],
      contract: "contracts/ItemNFT721.sol:ItemNFT721",
    });
    console.log("ItemNFT721 verified successfully");
  } catch (error) {
    console.error("Error verifying ItemNFT721:", error);
  }

  try {
    // Verify MagicToken
    console.log("Verifying MagicToken...");
    await run("verify:verify", {
      address: MAGIC_TOKEN_ADDRESS,
      constructorArguments: [OWNER_ADDRESS],
      contract: "contracts/MagicToken.sol:MagicToken",
    });
    console.log("MagicToken verified successfully");
  } catch (error) {
    console.error("Error verifying MagicToken:", error);
  }

  try {
    // Verify GameMechanics
    console.log("Verifying GameMechanics...");
    await run("verify:verify", {
      address: GAME_MECHANICS_ADDRESS,
      constructorArguments: [RESOURCE_NFT_ADDRESS, ITEM_NFT_ADDRESS],
      contract: "contracts/GameMechanics.sol:GameMechanics",
    });
    console.log("GameMechanics verified successfully");
  } catch (error) {
    console.error("Error verifying GameMechanics:", error);
  }

  try {
    // Verify Marketplace
    console.log("Verifying Marketplace...");
    await run("verify:verify", {
      address: MARKETPLACE_ADDRESS,
      constructorArguments: [
        OWNER_ADDRESS,
        MAGIC_TOKEN_ADDRESS,
        RESOURCE_NFT_ADDRESS,
        ITEM_NFT_ADDRESS
      ],
      contract: "contracts/Marketplace.sol:Marketplace",
    });
    console.log("Marketplace verified successfully");
  } catch (error) {
    console.error("Error verifying Marketplace:", error);
  }

  console.log("Contract verification complete!");
}

// Execute verification
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });