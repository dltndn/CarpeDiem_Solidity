import { ethers, network } from "hardhat";
import ethers2 from 'ethers';

const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("MiniLottery contract", function () {
  async function deployConractFixture() {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const HashLotteryContract = await ethers.deployContract("HashLottery");
    const HashiLotteryImplContract = await ethers.deployContract("HashLotteryImpl");

    // Fixtures can return anything you consider useful for your tests
    return { HashLotteryContract, HashiLotteryImplContract, owner, addr1, addr2, addr3 };
  }

  it.only("Should assign the total supply of tokens to the owner", async function () {
    const { HashLotteryContract, HashiLotteryImplContract, owner, addr1, addr2, addr3 } = await loadFixture(
      deployConractFixture
    );

    const betAmount = ethers.parseEther("0.07"); // 2 ETH

    await HashLotteryContract.initialize(owner, betAmount, 150)
    await HashLotteryContract.setImplementation(HashiLotteryImplContract.target)

    const result = await HashLotteryContract.calculateWinningResults([owner.address, addr1.address, addr2.address, addr3.address])
    console.log(result)

    const betFunc = 'bet()'
    const claimFunc = 'claimReward(uint256)'
    const getRecentGameIds = 'getRecentGameIds(address, uint256, uint256)'
    const getPlayersPerGameId = 'getPlayersPerGameId(uint256)'

    const HashLotteryContractR = (sender: any) => {
       return new ethers.Contract(
        HashLotteryContract.target,
        [
          ...HashLotteryContract.interface.fragments,
          `function ${betFunc}`,
          `function ${claimFunc}`,
          `function ${getRecentGameIds}`,
          `function ${getPlayersPerGameId}`
        ],
        sender,
      );
    }

    const players = [owner, addr1, addr2, addr3]

    for (const val of players) {
      const randomNum = Math.floor(Math.random() * 256);
      await HashLotteryContract.connect(val).setBettingKey(randomNum)
    }

    // fallback

    for (let i = 0; i < players.length; ++i) {
      const contract = HashLotteryContractR(players[i])
        const g = await contract[betFunc]({
            value: betAmount
        })
        console.log("gasPrice: ", g.gasPrice)
    }
    for (let i = players.length-1; i >= 0; --i) {
      const contract = HashLotteryContractR(players[i])
        const g = await contract[betFunc]({
            value: betAmount
        })
        console.log("gasPrice: ", g.gasPrice)
    }

    // const printData = async () => {
    //     const gameData = await HashLotteryContract.games("1")
    //     console.log("gameData: ", gameData);
    //     console.log("javascript winner spot: ", gameData[2])
    //     const gameData2 = await HashLotteryContract.games("2")
    //     console.log("gameData: ", gameData2);
    //     console.log("javascript winner spot: ", gameData2[2])
    //     console.log("owner balance", ethers.formatEther(await ethers.provider.getBalance(owner.address)))
    //     console.log("addr1 balance", ethers.formatEther(await ethers.provider.getBalance(addr1.address)))
    //     console.log("addr2 balance", ethers.formatEther(await ethers.provider.getBalance(addr2.address)))
    //     console.log("addr3 balance", ethers.formatEther(await ethers.provider.getBalance(addr3.address)))
    // }
    
    // await printData()

    const claimContract = HashLotteryContractR(owner)

    // const gamePlayers = await claimContract.getPlayersPerGameId("1")
    // console.log("players: ", gamePlayers)

    const gameInfo = await HashLotteryContract.games("1")
    console.log("gameInfo: ", gameInfo)
    const gameInfo2 = await HashLotteryContract.games("2")
    console.log("gameInfo2: ", gameInfo2)

        // none fallback
    // for (let j = 0; j<3; ++j) {
    //     for (let i = 0; i < players.length; ++i) {
    //         const g = await MiniLotteryContract.connect(players[i]).bet({
    //             value: betAmount,
    //         });
    //         console.log("gasPrice: ", g.gasPrice)
    //     }
    // }

    // const printData = async () => {
    //     const gameData = await MiniLotteryContract.bet2Games("1")
    //     console.log("gameData: ", gameData);
    //     console.log("javascript winner spot: ", gameData[2])
    //     const gameData2 = await MiniLotteryContract.bet2Games("2")
    //     console.log("gameData: ", gameData2);
    //     console.log("javascript winner spot: ", gameData2[2])
    //     console.log("owner balance", ethers.formatEther(await ethers.provider.getBalance(owner.address)))
    //     console.log("addr1 balance", ethers.formatEther(await ethers.provider.getBalance(addr1.address)))
    //     console.log("addr2 balance", ethers.formatEther(await ethers.provider.getBalance(addr2.address)))
    //     console.log("addr3 balance", ethers.formatEther(await ethers.provider.getBalance(addr3.address)))
    // }
    
    // await printData()

    // await MiniLotteryContract.connect(owner).claimReward("1", ethers.parseEther("2"))
    // await printData()

    // await MiniLotteryContract.connect(addr1).claimReward("1", ethers.parseEther("2"))
    // await printData()

    // await MiniLotteryContract.connect(addr2).claimReward("1", ethers.parseEther("2"))
    // await printData()

    // await MiniLotteryContract.connect(addr3).claimReward("1", ethers.parseEther("2"))
    // await printData()



    
    
    // const gamePlayers2 = await MiniLotteryContract.getPlayersPerGameId("2", ethers.parseEther("2"))
    // console.log("players: ", gamePlayers2)
    // await MiniLotteryContract.claimReward("1", ethers.parseEther("2"));
    // await MiniLotteryContract.claimReward("1", ethers.parseEther("10"));
    // await MiniLotteryContract.claimReward("1", ethers.parseEther("50"));
    // await MiniLotteryContract.claimReward("1", ethers.parseEther("250"));

    
  });
});
