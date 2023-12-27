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
  const players = await ethers.getSigners();
  const betAmount = ethers.parseEther("2"); // 2 ETH

  const Lottery = await ethers.getContractFactory("HashLotteryImpl");
  const lottery = Lottery.attach("0x4D8A127e888a29837f34f06a075afea709efB42d")
  
  // const res = await lottery.getPlayersPerGameId("7")
  // const res = await lottery.developerWallet()
  // const res = await lottery.gameCurrentId()
  // console.log(res)
  
  //@ts-ignore
  // await lottery.initialize("0xba054CE2143183d3246966DE9e49d4185B7d37f9", betAmount, 150)
  //@ts-ignore
  // await lottery.setImplementation("0xf18A314F92A1479Ee590d7a87cdde75304062ae1")
  // const result = await lottery.getPlayersPerGameId(13)

  // const result = await lottery.connect(players[1]).claimReward(12)
  // console.log(result)

  // const currentGameId = await lottery.gameCurrentId()
  //   console.log("currentGameId: ", currentGameId)

  for (let i=1; i<7; ++i) {
    //@ts-ignore
    const gameInfo = await lottery.games(i)
    console.log(`round ${i} info: `, gameInfo)
  }

  // for (let i=0; i<players.length; ++i) {
  //   console.log("set bettingKey")
  //   console.log(players[i].address)
  //  // @ts-ignore
  //   await lottery.connect(players[i]).setBettingKey((i + 1) * 8)
  // }

  // for (let i=0; i<players.length; ++i) {
  //   console.log("betting")
  //   console.log(players[i].address)
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

// 1
// hashLotterty: "0x4B2705334C48248CFCcbdC851eC2ea71B73a228A"
// impl: "0xf18A314F92A1479Ee590d7a87cdde75304062ae1"