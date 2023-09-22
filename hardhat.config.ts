import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

const ALCHEMY_API = "jPoJctKI-kiKK4OCedZzUgSaoBGbJvvf"
const PRIVATE_KEY = "4d83582560ff625a5f8533d65091f0c50367e75ed7885d2214e7aa9ba0886f55" // metamask dev account 0x2cC285279f6970d00F84f3034439ab8D29D04d97
const POLYGONSCAN_KEY = "WJ5IB75CKJ1D6775XGSI7TX3ANS4ZVRXB7"

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API}`,
      accounts: [PRIVATE_KEY]
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

