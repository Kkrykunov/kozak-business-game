import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "solidity-docgen";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 'auto'
    },
    whitechain: {
      url: process.env.WHITECHAIN_RPC_URL,
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 'auto'
    }
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY as string,
      whitechain: 'YOUR_WHITECHAIN_API_KEY'
    }
  },
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: true,
  }
};

export default config;