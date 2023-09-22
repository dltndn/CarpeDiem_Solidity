import { ethers, network } from "hardhat";

const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("MiniLottery contract", function () {
  async function deployConractFixture() {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const MiniLotteryContract = await ethers.deployContract("MiniLottery");

    // Fixtures can return anything you consider useful for your tests
    return { MiniLotteryContract, owner, addr1, addr2, addr3 };
  }

  it.only("Should assign the total supply of tokens to the owner", async function () {
    const { MiniLotteryContract, owner, addr1, addr2, addr3 } = await loadFixture(
      deployConractFixture
    );

    const players = [owner, addr1, addr2, addr3]

    const betAmount = ethers.parseEther("2"); // 2 ETH
    
    for (let j = 0; j<4; ++j) {
        for (let i = 0; i < players.length; ++i) {
            const g = await MiniLotteryContract.connect(players[i]).bet({
                value: betAmount,
            });
            console.log("gasPrice: ", g.gasPrice)
        }
    }

    
    const gameData = await MiniLotteryContract.bet2Games("1")
    console.log("gameData: ", gameData);
    const gameData2 = await MiniLotteryContract.bet2Games("2")
    console.log("gameData: ", gameData2);

    const gamePlayers = await MiniLotteryContract.getPlayersPerGameId("1", ethers.parseEther("2"))
    console.log("players: ", gamePlayers)
    const gamePlayers2 = await MiniLotteryContract.getPlayersPerGameId("2", ethers.parseEther("2"))
    console.log("players: ", gamePlayers2)

    
  });
});
