import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

const ALCHEMY_API = process.env.ALCHEMY_API

const PRIVATE_KEYS = [
  process.env.PRIVATE_KEY1 ? process.env.PRIVATE_KEY1 : "", // metamask 0x2cC285279f6970d00F84f3034439ab8D29D04d97 
  process.env.PRIVATE_KEY2 ? process.env.PRIVATE_KEY2 : "", // metamask 0x1e1864802DcF4A0527EF4315Da37D135f6D1B64B
  process.env.PRIVATE_KEY3 ? process.env.PRIVATE_KEY3 : "", // metamask 0x521D5d2d40C80BAe1fec2e75B76EC03eaB82b4E0
  process.env.PRIVATE_KEY4 ? process.env.PRIVATE_KEY4 : "", // metamask 0xd397AEc78be7fC14ADE2D2b5F03232b04A7AB42E
] 
const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY ? process.env.POLYGONSCAN_KEY : "";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API}`,
      accounts: PRIVATE_KEYS
    }
  },
  etherscan: {
    apiKey: {
      mumbai: POLYGONSCAN_KEY,
    }
  }
};

export default config;

task("accounts", "Prints the list of accounts and their balances", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    // @ts-ignore
    const balance = await account.eth_getBalance()
    console.log(`주소: ${account.address}, 잔고: ${balance.toString()}`);
  }
});

