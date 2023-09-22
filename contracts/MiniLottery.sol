// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "hardhat/console.sol";

/// @custom:security-contact james98099@gmail.com
contract MiniLottery is Ownable, AccessControl, Initializable {
    bytes32 public constant SET_MANAGEMENT_ROLE = keccak256("SET_MANAGEMENT_ROLE");
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint8 public playerAmount;
    address private implementation; // implementation contract
    address public feeCollector; // 수수료 수취 지갑 주소

    // 게임 구조체
    struct Game {
        bytes32 targetBlockhash;
        bool prizeClaimed;
        mapping(uint8 => address) players;
    }

    // 진행 중인 게임 넘버
    Counters.Counter public bet2GameCurrentId;
    Counters.Counter public bet10GameCurrentId;
    Counters.Counter public bet50GameCurrentId;
    Counters.Counter public bet250GameCurrentId;

    // 저장데이터
    mapping(uint => Game) public bet2Games;
    mapping(uint => Game) public bet10Games;
    mapping(uint => Game) public bet50Games;
    mapping(uint => Game) public bet250Games;

    // constructor
    function initialize() public initializer {
        bet2GameCurrentId.increment();
        bet10GameCurrentId.increment();
        bet50GameCurrentId.increment();
        bet250GameCurrentId.increment();
        playerAmount = 4;
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(SET_MANAGEMENT_ROLE, msg.sender);
    }

    fallback() external {
        address impl = implementation;
        require(impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    // 수행 컨트랙 주소 수정
    function setImplementation(address _newImple) external onlyRole(SET_MANAGEMENT_ROLE) {
        require(_newImple != address(0));
        implementation = _newImple;
    }

    // 수수료 수취 지갑 주소 수정
    function setfeeCollector(address _new) external onlyRole(SET_MANAGEMENT_ROLE) {
        require(_new != address(0));
        implementation = _new;
    }

    // impl code

    // 베팅 수량별 gameId struct 리턴
    function _getGameIdStorage() internal returns (Counters.Counter storage) {
        if (msg.value == 2 ether) {
            return bet2GameCurrentId;
        } else if (msg.value == 10 ether) {
            return bet10GameCurrentId;
        } else if (msg.value == 50 ether) {
            return bet50GameCurrentId;
        } else if (msg.value == 250 ether) {
            return bet250GameCurrentId;
        } else {
            revert("Invalid bet amount.");
        }
    }

    // 베팅 수량별 gameId 리턴
    function _getGameId() internal view returns (uint) {
        if (msg.value == 2 ether) {
            return bet2GameCurrentId.current();
        } else if (msg.value == 10 ether) {
            return bet10GameCurrentId.current();
        } else if (msg.value == 50 ether) {
            return bet50GameCurrentId.current();
        } else if (msg.value == 250 ether) {
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

    // 게임 등록 과정
    function _bet(Game storage _gameData, uint _betAmount) internal returns (uint) {
        for (uint8 i = 0; i < playerAmount; i++) {
            if (_gameData.players[i] == address(0)) {
                if (i == 0) {
                    // 첫 참가자 - 이전 라운드의 당첨자 추첨을 위한 이전 블록의 해쉬값 입력
                    Game storage preGameData = _getGameData(_getGameId().sub(1), _betAmount);
                    preGameData.targetBlockhash = blockhash(block.number - 1);
                } else if (i == 3) {
                    // 마지막 참가자 - 현재 게임 ID 1 증가
                    Counters.Counter storage currentGameId = _getGameIdStorage();
                    currentGameId.increment();
                }
                _gameData.players[i] = msg.sender;
                return i + 1;
            }
        }
        revert("All players are already assigned.");
    }

    // 베팅 함수 - 2, 10, 50, 250개의 이더를 전송하며 실행해야 함
    function bet() payable external returns (uint) {
        uint gameId = _getGameId();
        Game storage gameData = _getGameData(gameId, msg.value);        

        uint playerIndex = _bet(gameData, msg.value);
        console.log("Player %d joined Game %d", playerIndex, gameId);
        return gameId;
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

        for (uint8 i = 0; i < playerAmount; ++i) {
            result[i] = gameData.players[i];
            console.log("Player %d seat on %d", result[i], i);
        }
        
        return result;
    }
}