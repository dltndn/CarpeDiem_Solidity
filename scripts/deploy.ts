import { ethers } from "hardhat";

async function main() {
  // deploy contract s
  // const lock = await ethers.deployContract("MiniLottery", [unlockTime], {
  //   value: lockedAmount,
  // });
  // const lottery = await ethers.deployContract("MiniLottery");

  // await lottery.waitForDeployment();

  // deploy contract e

  // execute deployed contract s
  const [owner, addr1, addr2, addr3] = await ethers.getSigners();
  const betAmount = ethers.parseEther("2"); // 2 ETH

  const Lottery = await ethers.getContractFactory("MiniLottery");
  const lottery = Lottery.attach("0x6f5F75A7C9E0DE8A60b58BF440C6cA86DF0D993F")

  const players = [owner, addr1, addr2, addr3]

  
  // players.forEach(async (val) => {
  //   // @ts-ignore
  //   await lottery.bet({
  //     from: val,
  //     value: betAmount
  //   })
  // })
  // @ts-ignore
  await lottery.bet({
    from: addr2,
    value: betAmount
  })
  // @ts-ignore
  const data = await lottery.bet2Games("1")
  // execute deployed contract e



  console.log(
    `data = ${JSON.stringify(data)}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
