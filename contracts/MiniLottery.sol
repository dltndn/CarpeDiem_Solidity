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

    uint public playerAmount;
    address private implementation; // implementation contract
    address payable public developerWallet; // 수수료 수취 지갑 주소
    uint public managementFee; // 개발자 수수료(베팅금에서 차감) - ex) 100 -> 1%

    event Bet(uint indexed gameId, uint indexed betAmount, uint spot);
    event EnterFirstPlayer(uint preBlockNumber , bytes32 preBlockhash, uint preWinnerSpot);
    event ClaimReward(uint gameId, uint indexed betAmount);
    event ChangedManagement(bool isChanged);

    // 게임 구조체
    struct Game {
        uint targetBlockNumber;
        bytes32 targetBlockhash;
        uint winnerSpot;
        bool rewardClaimed;
        mapping(uint => address) players;
    }

    // 진행 중인 게임 넘버
    Counters.Counter public bet2GameCurrentId;
    Counters.Counter public bet10GameCurrentId;
    Counters.Counter public bet50GameCurrentId;
    Counters.Counter public bet250GameCurrentId;

    // 게임 데이터
    mapping(uint => Game) public bet2Games;
    mapping(uint => Game) public bet10Games;
    mapping(uint => Game) public bet50Games;
    mapping(uint => Game) public bet250Games;

    // 유저 참가 게임id 내역
    mapping(address => uint[]) public playerBet2GameId;
    mapping(address => uint[]) public playerBet10GameId;
    mapping(address => uint[]) public playerBet50GameId;
    mapping(address => uint[]) public playerBet250GameId;

    // constructor
    function initialize(address payable _developerWallet) public initializer {
        bet2GameCurrentId.increment();
        bet10GameCurrentId.increment();
        bet50GameCurrentId.increment();
        bet250GameCurrentId.increment();
        playerAmount = 4;
        managementFee = 100;
        developerWallet = _developerWallet;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SET_MANAGEMENT_ROLE, msg.sender);
    }

    fallback() payable external {
        address impl = implementation;
        require(implementation != address(0));
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
        emit ChangedManagement(true);
    }

    // 수수료 수취 지갑 주소 수정
    function setfeeCollector(address _new) external onlyRole(SET_MANAGEMENT_ROLE) {
        require(_new != address(0));
        implementation = _new;
        emit ChangedManagement(true);
    }

    // 개발자 수수료 수정
    function setManagementFee(uint _fee) external onlyRole(SET_MANAGEMENT_ROLE) {
        managementFee = _fee;
        emit ChangedManagement(true);
    }
}