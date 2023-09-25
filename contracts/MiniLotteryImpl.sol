// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "./MiniLottery.sol";

contract MiniLotteryImpl is MiniLottery {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // 베팅 수량별 gameId struct 리턴
    function _getGameIdStorage(uint _betAmount) internal view returns (Counters.Counter storage) {
        if (_betAmount == 2 ether) {
            return bet2GameCurrentId;
        } else if (_betAmount == 10 ether) {
            return bet10GameCurrentId;
        } else if (_betAmount == 50 ether) {
            return bet50GameCurrentId;
        } else if (_betAmount == 250 ether) {
            return bet250GameCurrentId;
        } else {
            revert("Invalid bet amount.");
        }
    }

    // 베팅 수량별 gameId 리턴
    function _getGameId(uint _betAmount) internal view returns (uint) {
        if (_betAmount == 2 ether) {
            return bet2GameCurrentId.current();
        } else if (_betAmount == 10 ether) {
            return bet10GameCurrentId.current();
        } else if (_betAmount == 50 ether) {
            return bet50GameCurrentId.current();
        } else if (_betAmount == 250 ether) {
            return bet250GameCurrentId.current();
        } else {
            revert("Invalid bet amount.");
        }
    }

    // 베팅 수량별 gameData 리턴
    function _getGameData(uint _gameId, uint _betAmount) internal view returns (Game storage) {
        if (_betAmount == 2 ether) {
            return bet2Games[_gameId];
        } else if (_betAmount == 10 ether) {
            return bet10Games[_gameId];
        } else if (_betAmount == 50 ether) {
            return bet50Games[_gameId];
        } else if (_betAmount == 250 ether) {
            return bet250Games[_gameId];
        } else {
            revert("Invalid bet amount.");
        }
    }

    // 베팅 수량별 gameId 등록
    function _insertGameId(uint _gameId, uint _betAmount) internal {
        if (_betAmount == 2 ether) {
            playerBet2GameId[msg.sender].push(_gameId);
        } else if (_betAmount == 10 ether) {
            playerBet10GameId[msg.sender].push(_gameId);
        } else if (_betAmount == 50 ether) {
            playerBet50GameId[msg.sender].push(_gameId);
        } else if (_betAmount == 250 ether) {
            playerBet250GameId[msg.sender].push(_gameId);
        } else {
            revert("Invalid bet amount.");
        }
    }

    // 게임 등록 과정
    function _bet(Game storage _gameData, uint _betAmount) internal returns (uint) {
        for (uint i = 0; i < playerAmount; i++) {
            if (_gameData.players[i] == address(0)) {
                uint currentGameId = _getGameId(_betAmount);
                if (i == 0) {
                    // 첫 참가자 - 이전 라운드의 당첨자 추첨을 위한 이전 블록의 해쉬값 입력
                    Game storage preGameData = _getGameData(currentGameId.sub(1), _betAmount);
                    uint preBlockNum = block.number.sub(1);
                    preGameData.targetBlockNumber = preBlockNum;
                    bytes32 _targetBlockhash = blockhash(block.number.sub(1));
                    preGameData.targetBlockhash = _targetBlockhash;
                    uint _winnerSpot = uint(_targetBlockhash).mod(4);
                    preGameData.winnerSpot = _winnerSpot.add(1);
                    _gameData.players[i] = msg.sender;
                    _insertGameId(currentGameId, _betAmount);
                    emit Bet(currentGameId, _betAmount, i + 1);
                    emit EnterFirstPlayer(preBlockNum, _targetBlockhash, _winnerSpot.add(1));
                } else if (i == 3) {
                    // 마지막 참가자 - 현재 게임 ID 1 증가
                    Counters.Counter storage currentGameIdStruct = _getGameIdStorage(_betAmount);
                    _gameData.players[i] = msg.sender;
                    _insertGameId(currentGameId, _betAmount);
                    console.log("before gameId: %d", _getGameId(_betAmount));
                    emit Bet(currentGameId, _betAmount, i + 1);
                    currentGameIdStruct.increment();
                    console.log("after gameId: %d", _getGameId(_betAmount));
                } else {
                    _gameData.players[i] = msg.sender;
                    _insertGameId(_getGameId(_betAmount), _betAmount);
                    emit Bet(currentGameId, _betAmount, i + 1);
                }
                return i + 1;
            } else if (_gameData.players[i] == msg.sender) {
                revert("Player is already assigned.");
            }
        }
        revert("All players are already assigned.");
    }

    // 베팅 함수 - 2, 10, 50, 250개의 이더를 전송하며 실행해야 함
    function bet() payable external returns (uint, uint) {
        require(msg.sender != address(0));
        uint gameId = _getGameId(msg.value);
        Game storage gameData = _getGameData(gameId, msg.value);        

        uint playerIndex = _bet(gameData, msg.value);
        uint fee = msg.value.div(managementFee);
        developerWallet.transfer(fee);
        console.log("Player %d joined Game %d", playerIndex, gameId);
        console.log("Transfer to developer wallet %d", fee);
        return (playerIndex, msg.value);
    }

    // 당첨여부를 검증하는 함수
    function isWinner(address _user, uint _gameId, uint _betAmount) internal view returns (Game storage) {
        Game storage game = _getGameData(_gameId, _betAmount);
        // hash값 존재여부 확인
        require (game.targetBlockhash != 0, "Empty hash value");
        // 당첨여부 확인
        require(game.players[game.winnerSpot.sub(1)] == _user, "Not winner");
        // 당첨금 수령여부 확인
        require(!game.rewardClaimed, "Already claimed");
        return game;
    }

    // 당첨금을 계산해주는 함수
    function getRewardAmount(uint _betAmount) internal view returns (uint) {
        uint fee = _betAmount.div(managementFee).mul(playerAmount);
        console.log("fee : %d", fee);
        if (_betAmount == 2 ether) {
            return uint(8 ether).sub(fee);
        } else if (_betAmount == 10 ether) {
            return uint(40 ether).sub(fee);
        } else if (_betAmount == 50 ether) {
            return uint(200 ether).sub(fee);
        } else if (_betAmount == 250 ether) {
            return uint(1000 ether).sub(fee);
        } else {
            revert("Invalid bet amount.");
        }
    }

    // 당첨자가 당청금을 수거하는 함수
    function claimReward(uint _gameId, uint _betAmount) payable external returns (uint, uint) {
        require(msg.sender != address(0));
        Game storage game = isWinner(msg.sender, _gameId, _betAmount);
        // 당첨금 계산
        uint reward = getRewardAmount(_betAmount);
        payable(msg.sender).transfer(reward);
        game.rewardClaimed = true;
        emit ClaimReward(_gameId, _betAmount);
        return (_gameId, reward);
    }

    // gameId 별 참가자 지갑주소 가져오기
    function getPlayersPerGameId(uint _gameId, uint _betAmount) external view returns (address[4] memory) {
        address[4] memory result;
    
        Game storage gameData;

        if (_betAmount == 2 ether) {
            gameData = bet2Games[_gameId];
        } else if (_betAmount == 10 ether) {
            gameData = bet10Games[_gameId];
        } else if (_betAmount == 50 ether) {
            gameData = bet50Games[_gameId];
        } else if (_betAmount == 250 ether) {
            gameData = bet250Games[_gameId];
        } else {
            revert("Invalid bet amount.");
        }

        for (uint i = 0; i < playerAmount; ++i) {
            result[i] = gameData.players[i];
            console.log("Player %d seat on %d", result[i], i);
        }
        
        return result;
    }

    // 참가 비용 환불 함수
    function refund(uint256 _gameId, uint _betAmount) payable external onlyRole(SET_MANAGEMENT_ROLE) {
        Game storage game = _getGameData(_gameId, _betAmount);
        // 이전게임 hash 데이터 추가
        Game storage preGameData = _getGameData(_getGameId(_betAmount).sub(1), _betAmount);
        preGameData.targetBlockNumber = block.number.sub(1);
        bytes32 _targetBlockhash = blockhash(block.number.sub(1));
        preGameData.targetBlockhash = _targetBlockhash;
        uint _winnerSpot = uint(_targetBlockhash).mod(4);
        preGameData.winnerSpot = _winnerSpot.add(1);
        // 수수료 제외 참가비용 환불
        uint refundAmount = _betAmount.sub(_betAmount.div(managementFee));
        for (uint i=0; i<4; ++i) {
            if (game.players[i] != address(0)) {
                payable(game.players[i]).transfer(refundAmount);
            }
        }
        game.rewardClaimed = true;
        Counters.Counter storage currentGameId = _getGameIdStorage(_betAmount);
        currentGameId.increment();
    }
}