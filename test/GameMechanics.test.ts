import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("GameMechanics", function () {
  let gameMechanics: Contract;
  let resourceNFT: Contract;
  let itemNFT: Contract;
  let owner: any;
  let player: any;

  beforeEach(async function () {
    [owner, player] = await ethers.getSigners();

    const ResourceNFT1155 = await ethers.getContractFactory("ResourceNFT1155");
    resourceNFT = await ResourceNFT1155.deploy(owner.address);
    
    const ItemNFT721 = await ethers.getContractFactory("ItemNFT721");
    itemNFT = await ItemNFT721.deploy(owner.address);
    
    const GameMechanics = await ethers.getContractFactory("GameMechanics");
    gameMechanics = await GameMechanics.deploy(await resourceNFT.getAddress(), await itemNFT.getAddress());

    await resourceNFT.addAuthorizedContract(await gameMechanics.getAddress());
    await itemNFT.addAuthorizedContract(await gameMechanics.getAddress());
  });

  it("Should search resources", async function () {
    await gameMechanics.connect(player).searchResources();
    
    // Instead of checking for specific resource, check that player has some resources
    // Sum all resource balances
    let totalResources = 0;
    for(let i = 0; i < 6; i++) {
      let balance = await resourceNFT.balanceOf(player.address, i);
      totalResources += Number(balance);
    }
    
    // Player should have 3 resources after search
    expect(totalResources).to.equal(3);
  });

  it("Should craft item", async function () {
    // Add owner to authorized contracts for direct minting in test
    await resourceNFT.addAuthorizedContract(owner.address);
    
    // Give player enough resources
    await resourceNFT.connect(owner).mint(player.address, 1, 3); // 3 Iron
    await resourceNFT.connect(owner).mint(player.address, 0, 1); // 1 Wood
    await resourceNFT.connect(owner).mint(player.address, 3, 1); // 1 Leather
    
    await gameMechanics.connect(player).craftItem(0); // Craft Kozak Sword
    
    const itemBalance = await itemNFT.balanceOf(player.address);
    expect(itemBalance).to.equal(1);
  });
});