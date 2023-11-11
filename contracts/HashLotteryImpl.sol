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

    // 지갑 주소들의 hash값 반환
    // function _hashPlayerAddress(address[4] memory _players) internal view returns (bytes20) {
    //     return(ripemd160(abi.encodePacked(
    //         _players[0], bettingKeys[_players[0]],
    //         _players[1], bettingKeys[_players[1]],
    //         _players[2], bettingKeys[_players[2]],
    //         _players[3], bettingKeys[_players[3]]
    //         )));
    // }

    // 게임 등록 과정
    function _bet(Game storage _gameData, uint _currentGameId) internal returns (uint) {
        for (uint i = 0; i < playerAmount; i++) {
            if (_gameData.players[i] == address(0)) {
                uint currentGameId = _getGameId();
                if (i == 3) {
                    // 마지막 참가자 - 현재 게임 ID 1 증가
                    // 당첨자 기록 코드 수행
                    _gameData.players[i] = msg.sender;
                    (bytes20 hashValue, uint _winnerSpot) = calculateWinningResults(getPlayersPerGameId(currentGameId));
                    _gameData.resultHash = hashValue;
                    _gameData.winnerSpot = _winnerSpot;
                    Counters.Counter storage currentGameIdStruct = _getGameIdStorage();
                    emit Bet(_currentGameId, msg.sender, i + 1);
                    emit EnterLastPlayer(_currentGameId, hashValue, _winnerSpot);
                    currentGameIdStruct.increment();
                } else {
                    _gameData.players[i] = msg.sender;
                    emit Bet(_currentGameId, msg.sender, i + 1);
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
        require(bettingKeys[msg.sender] != 0, "bettingKey is empty.");
        require(msg.value == betAmount, "Incorrect betting amount.");
        uint gameId = _getGameId();
        Game storage gameData = _getGameData(gameId);        

        uint playerIndex = _bet(gameData, gameId);
        uint fee = msg.value.div(managementFee);
        developerWallet.transfer(fee);
        return (playerIndex, msg.value);
    }

    // 당첨여부를 검증하는 함수
    function isWinner(address _user, uint _gameId) internal view returns (Game storage) {
        Game storage game = _getGameData(_gameId);
        // hash값 존재여부 확인
        require (game.resultHash != 0, "Empty hash value.");
        // 당첨여부 확인
        require(game.players[game.winnerSpot.sub(1)] == _user, "Not winner.");
        // 당첨금 수령여부 확인
        require(!game.rewardClaimed, "Already claimed.");
        return game;
    }

    // 당첨금을 계산해주는 함수
    function getRewardAmount() internal view returns (uint) {
        uint fee = betAmount.div(managementFee);
        return betAmount.sub(fee).mul(playerAmount);
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
        require(game.resultHash != 0, "This game is finished.");
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
}
    // player가 참여한 amount개 게임 id를 가장 최근 - index부터 내림차순으로 가져오기 
    // ex) _amount = 2, _index = 3, arr = [0, 1, 2, 3, 4, 5, 6] -> [2, 3]
    // function getRecentGameIds(address _player, uint _amount, uint _index) view external returns (uint[] memory) {
    //     uint[] memory ids = playerGameId[_player];

    //     uint startIndex;
    //     uint endIndex;
    //     if (ids.length <= _index) {
    //         startIndex = ids.length.sub(1);
    //     } else {
    //         startIndex = ids.length.sub(_index + 1);
    //     }
    //     if (startIndex <= _amount - 1) {
    //         endIndex = 0;
    //     } else {
    //         endIndex = startIndex.sub(_amount - 1);
    //     }
    //     uint[] memory result = new uint[](_amount);
    //     uint resultIndex = 0;
    //     for (uint i=startIndex; i>=endIndex; --i) {
    //         result[resultIndex] = ids[i];
    //         resultIndex++;
    //     }
    //     return result;
    // }
