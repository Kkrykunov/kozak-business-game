import { ethers } from "hardhat";

async function main() {
  console.log("Deploying Kozak Game contracts...");

  // Get the signers (deployer account)
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying with account: ${deployer.address}`);

  // Deploy ResourceNFT1155
  const ResourceNFT1155 = await ethers.getContractFactory("ResourceNFT1155");
  const resourceNFT = await ResourceNFT1155.deploy(deployer.address);
  await resourceNFT.waitForDeployment();
  console.log(`ResourceNFT1155 deployed to: ${await resourceNFT.getAddress()}`);

  // Deploy ItemNFT721
  const ItemNFT721 = await ethers.getContractFactory("ItemNFT721");
  const itemNFT = await ItemNFT721.deploy(deployer.address);
  await itemNFT.waitForDeployment();
  console.log(`ItemNFT721 deployed to: ${await itemNFT.getAddress()}`);

  // Deploy MagicToken
  const MagicToken = await ethers.getContractFactory("MagicToken");
  const magicToken = await MagicToken.deploy(deployer.address);
  await magicToken.waitForDeployment();
  console.log(`MagicToken deployed to: ${await magicToken.getAddress()}`);

  // Deploy GameMechanics
  const GameMechanics = await ethers.getContractFactory("GameMechanics");
  const gameMechanics = await GameMechanics.deploy(
    await resourceNFT.getAddress(), 
    await itemNFT.getAddress()
  );
  await gameMechanics.waitForDeployment();
  console.log(`GameMechanics deployed to: ${await gameMechanics.getAddress()}`);

  // Deploy Marketplace
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(
    deployer.address,
    await magicToken.getAddress(),
    await resourceNFT.getAddress(),
    await itemNFT.getAddress()
  );
  await marketplace.waitForDeployment();
  console.log(`Marketplace deployed to: ${await marketplace.getAddress()}`);

  // Setup permissions
  console.log("Setting up permissions...");
  
  // Authorize GameMechanics to mint and burn resources
  await resourceNFT.addAuthorizedContract(await gameMechanics.getAddress());
  console.log("GameMechanics authorized on ResourceNFT1155");
  
  // Authorize GameMechanics to mint items
  await itemNFT.addAuthorizedContract(await gameMechanics.getAddress());
  console.log("GameMechanics authorized on ItemNFT721");
  
  // Authorize Marketplace to mint MagicTokens
  await magicToken.setMarketplaceAddress(await marketplace.getAddress());
  console.log("Marketplace authorized on MagicToken");

  console.log("All contracts deployed and initialized successfully!");
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });