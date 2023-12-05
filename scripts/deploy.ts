import { ethers } from "hardhat";

async function main() {
  // deploy contract s
  // const hashLottery = await ethers.deployContract("HashLottery");
  // const hashLotteryImpl = await ethers.deployContract("HashLotteryImpl");

  // await hashLottery.waitForDeployment();
  // await hashLotteryImpl.waitForDeployment();

  // console.log("hashLottery: ", hashLottery.target)
  // console.log("hashLotteryImpl: ", hashLotteryImpl.target)

  // deploy contract e

  // execute deployed contract s
  // const players = await ethers.getSigners();
  // const betAmount = ethers.parseEther("0.001"); // 2 ETH

  const Lottery = await ethers.getContractFactory("HashLotteryImpl");
  const lottery = Lottery.attach("0x36a99388ee9AB8c9b6DbDFf12A46926baBC1F0d1")
  
  // const res = await lottery.getPlayersPerGameId("7")
  // const res = await lottery.developerWallet()
  // const res = await lottery.gameCurrentId()
  // console.log(res)
  
  //@ts-ignore
  // await lottery.initialize("0xB6C9011d74B1149fdc269530d51b4A594D97Fd04", ethers.parseEther("0.001"))
  //@ts-ignore
  // await lottery.setImplementation("0x09270CDC4D6C9aD037aE2E88478F8BdC6bc1563b")
  // const result = await lottery.getPlayersPerGameId(13)

  // const result = await lottery.connect(players[1]).claimReward(12)
  // console.log(result)

  // const currentGameId = await lottery.gameCurrentId()
  //   console.log("currentGameId: ", currentGameId)

  
  // for (let i=1; i<players.length; ++i) {
  //  // @ts-ignore
  //   await lottery.connect(players[i]).bet({
  //     value: betAmount
  //   })
  // }
    //  // @ts-ignore
    // await lottery.connect(players[3]).bet({
    //   value: betAmount
    // })
  // execute deployed contract e


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
