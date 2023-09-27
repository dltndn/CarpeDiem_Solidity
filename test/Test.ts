import { ethers, network } from "hardhat";
import ethers2 from 'ethers';

const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("MiniLottery contract", function () {
  async function deployConractFixture() {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const MiniLotteryContract = await ethers.deployContract("MiniLottery");
    const MiniLotteryImplContract = await ethers.deployContract("MiniLotteryImpl");

    // Fixtures can return anything you consider useful for your tests
    return { MiniLotteryContract, MiniLotteryImplContract, owner, addr1, addr2, addr3 };
  }

  it.only("Should assign the total supply of tokens to the owner", async function () {
    const { MiniLotteryContract, MiniLotteryImplContract, owner, addr1, addr2, addr3 } = await loadFixture(
      deployConractFixture
    );

    await MiniLotteryContract.initialize(owner)
    await MiniLotteryContract.setImplementation(MiniLotteryImplContract.target)

    const betFunc = 'bet()'
    const claimFunc = 'claimReward(uint256, uint256)'
    const getRecentGameIds = 'getRecentGameIds(address, uint256, uint256, uint256)'

    const MiniLotteryContractR = (sender: any) => {
       return new ethers.Contract(
        MiniLotteryContract.target,
        [
          ...MiniLotteryContract.interface.fragments,
          `function ${betFunc}`,
          `function ${claimFunc}`,
          `function ${getRecentGameIds}`
        ],
        sender,
      );
    }

    const players = [owner, addr1, addr2, addr3]

    const betAmount = ethers.parseEther("2"); // 2 ETH

    // fallback

    for (let j = 0; j<5; ++j) {
        for (let i = 0; i < players.length; ++i) {
          const contract = MiniLotteryContractR(players[i])
            const g = await contract[betFunc]({
                value: betAmount
            })
            console.log("gasPrice: ", g.gasPrice)
        }
    }

    const printData = async () => {
        const gameData = await MiniLotteryContract.bet2Games("1")
        console.log("gameData: ", gameData);
        console.log("javascript winner spot: ", gameData[2])
        const gameData2 = await MiniLotteryContract.bet2Games("2")
        console.log("gameData: ", gameData2);
        console.log("javascript winner spot: ", gameData2[2])
        console.log("owner balance", ethers.formatEther(await ethers.provider.getBalance(owner.address)))
        console.log("addr1 balance", ethers.formatEther(await ethers.provider.getBalance(addr1.address)))
        console.log("addr2 balance", ethers.formatEther(await ethers.provider.getBalance(addr2.address)))
        console.log("addr3 balance", ethers.formatEther(await ethers.provider.getBalance(addr3.address)))
    }
    
    await printData()

    const claimContract = MiniLotteryContractR(owner)
    const res = await claimContract[getRecentGameIds](addr1, betAmount, 2, 2);

    console.log("res: ", res)

    const gamePlayers = await MiniLotteryContract.getPlayersPerGameId("1", ethers.parseEther("2"))
    console.log("players: ", gamePlayers)

    


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
