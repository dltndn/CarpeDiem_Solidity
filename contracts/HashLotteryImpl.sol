// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "./HashLottery.sol";

contract HashLotteryImpl is HashLottery {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // 베팅 수량별 gameId struct 리턴
    function _getGameIdStorage() internal view returns (Counters.Counter storage) {
        return gameCurrentId;
    }

    // 베팅 수량별 gameId 리턴
    function _getGameId() internal view returns (uint) {  
        return gameCurrentId.current(); 
    }

    // gameData 리턴
    function _getGameData(uint _gameId) internal view returns (Game storage) {
        return games[_gameId];
    }

    // 베팅 수량별 gameId 등록
    function _insertGameId(uint _gameId) internal {
        playerGameId[msg.sender].push(_gameId);
    }

    // 게임 등록 과정
    function _bet(Game storage _gameData) internal returns (uint) {
        for (uint i = 0; i < playerAmount; i++) {
            if (_gameData.players[i] == address(0)) {
                uint currentGameId = _getGameId();
                if (i == 0) {
                    // 첫 참가자 - 이전 라운드의 당첨자 추첨을 위한 이전 블록의 해쉬값 입력
                    Game storage preGameData = _getGameData(currentGameId.sub(1));
                    uint preBlockNum = block.number.sub(1);
                    preGameData.targetBlockNumber = preBlockNum;
                    bytes32 _targetBlockhash = blockhash(block.number.sub(1));
                    preGameData.targetBlockhash = _targetBlockhash;
                    uint _winnerSpot = uint(_targetBlockhash).mod(4);
                    preGameData.winnerSpot = _winnerSpot.add(1);
                    _gameData.players[i] = msg.sender;
                    _insertGameId(currentGameId);
                    emit Bet(currentGameId, msg.sender, i + 1);
                    emit EnterFirstPlayer(currentGameId - 1, preBlockNum, _winnerSpot.add(1));
                } else if (i == 3) {
                    // 마지막 참가자 - 현재 게임 ID 1 증가
                    Counters.Counter storage currentGameIdStruct = _getGameIdStorage();
                    _gameData.players[i] = msg.sender;
                    _insertGameId(currentGameId);
                    emit Bet(currentGameId, msg.sender, i + 1);
                    currentGameIdStruct.increment();
                } else {
                    _gameData.players[i] = msg.sender;
                    _insertGameId(_getGameId());
                    emit Bet(currentGameId, msg.sender, i + 1);
                }
                return i + 1;
            } else if (_gameData.players[i] == msg.sender) {
                revert("Player is already assigned.");
            }
        }
        revert("All players are already assigned.");
    }

    // 베팅 함수 - betAmount 만큼의 이더를 전송하며 실행해야 함
    function bet() payable external whenNotPaused returns (uint, uint) {
        require(msg.sender != address(0));
        require(msg.value == betAmount, "Incorrect betting amount.");
        uint gameId = _getGameId();
        Game storage gameData = _getGameData(gameId);        

        uint playerIndex = _bet(gameData);
        uint fee = msg.value.div(managementFee);
        developerWallet.transfer(fee);
        return (playerIndex, msg.value);
    }

    // 당첨여부를 검증하는 함수
    function isWinner(address _user, uint _gameId) internal view returns (Game storage) {
        Game storage game = _getGameData(_gameId);
        // hash값 존재여부 확인
        require (game.targetBlockhash != 0, "Empty hash value");
        // 당첨여부 확인
        require(game.players[game.winnerSpot.sub(1)] == _user, "Not winner");
        // 당첨금 수령여부 확인
        require(!game.rewardClaimed, "Already claimed");
        return game;
    }

    // 당첨금을 계산해주는 함수
    function getRewardAmount() internal view returns (uint) {
        uint fee = betAmount.div(managementFee).mul(playerAmount);
        return betAmount.sub(fee);
    }

    // 당첨자가 당청금을 수거하는 함수
    function claimReward(uint _gameId) payable external whenNotPaused returns (uint, uint) {
        require(msg.sender != address(0));
        Game storage game = isWinner(msg.sender, _gameId);
        // 당첨금 계산
        uint reward = getRewardAmount();
        payable(msg.sender).transfer(reward);
        game.rewardClaimed = true;
        emit ClaimReward(_gameId, msg.sender, reward);
        return (_gameId, reward);
    }

    // 참가자 지갑주소 가져오기
    function getPlayersPerGameId(uint _gameId) public view returns (address[4] memory) {
        address[4] memory result;
    
        Game storage gameData = games[_gameId];

        for (uint i = 0; i < playerAmount; ++i) {
            result[i] = gameData.players[i];
        }
        return result;
    }

    // 참가 비용 환불 함수
    function refund(uint256 _gameId) payable external onlyRole(SET_MANAGEMENT_ROLE) {
        Game storage game = _getGameData(_gameId);
        // 이전게임 hash 데이터 추가
        Game storage preGameData = _getGameData(_getGameId().sub(1));
        preGameData.targetBlockNumber = block.number.sub(1);
        bytes32 _targetBlockhash = blockhash(block.number.sub(1));
        preGameData.targetBlockhash = _targetBlockhash;
        uint _winnerSpot = uint(_targetBlockhash).mod(4);
        preGameData.winnerSpot = _winnerSpot.add(1);
        // 수수료 제외 참가비용 환불
        uint refundAmount = betAmount.sub(betAmount.div(managementFee));
        for (uint i=0; i<4; ++i) {
            if (game.players[i] != address(0)) {
                payable(game.players[i]).transfer(refundAmount);
            }
        }
        game.rewardClaimed = true;
        Counters.Counter storage currentGameId = _getGameIdStorage();
        currentGameId.increment();
    }

    // player가 참여한 amount개 게임 id를 가장 최근 - index부터 내림차순으로 가져오기 
    // ex) _amount = 2, _index = 3, arr = [0, 1, 2, 3, 4, 5, 6] -> [2, 3]
    function getRecentGameIds(address _player, uint _amount, uint _index) view external returns (uint[] memory) {
        uint[] memory ids = playerGameId[_player];

        uint startIndex;
        uint endIndex;
        if (ids.length <= _index) {
            startIndex = ids.length.sub(1);
        } else {
            startIndex = ids.length.sub(_index + 1);
        }
        if (startIndex <= _amount - 1) {
            endIndex = 0;
        } else {
            endIndex = startIndex.sub(_amount - 1);
        }
        uint[] memory result = new uint[](_amount);
        uint resultIndex = 0;
        for (uint i=startIndex; i>=endIndex; --i) {
            result[resultIndex] = ids[i];
            resultIndex++;
        }
        return result;
    }
}