import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

const ALCHEMY_API = "jPoJctKI-kiKK4OCedZzUgSaoBGbJvvf"
const PRIVATE_KEYS = [
  "4d83582560ff625a5f8533d65091f0c50367e75ed7885d2214e7aa9ba0886f55", // metamask 0x2cC285279f6970d00F84f3034439ab8D29D04d97 
  "79f05afa9b83396802184c0b977a66b759a1850b9395b37bf258833b1d666875", // metamask 0x1e1864802DcF4A0527EF4315Da37D135f6D1B64B
  "baafe14ae33e32ed327abd6473d30c7dd51ec1e50615c42d55a1bd2b5b5cc477", // metamask 0x521D5d2d40C80BAe1fec2e75B76EC03eaB82b4E0
  "b135ddf618b9a10872ca0407b6d1fd7d4e9eb881588c4491d949a43eb44dba65", // metamask 0xd397AEc78be7fC14ADE2D2b5F03232b04A7AB42E
] 
const POLYGONSCAN_KEY = "WJ5IB75CKJ1D6775XGSI7TX3ANS4ZVRXB7"

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

