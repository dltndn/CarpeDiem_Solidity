// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";

/// @custom:security-contact james98099@gmail.com
contract HashLottery is Ownable, AccessControl, Initializable, Pausable {
    bytes32 public constant SET_MANAGEMENT_ROLE = keccak256("SET_MANAGEMENT_ROLE");
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint public playerAmount; // 한 게임당 참여하는 플레이어 수
    uint public betAmount; // 베팅 수량
    address private implementation; // implementation contract
    address payable public developerWallet; // 수수료 수취 지갑 주소
    uint public managementFee; // 개발자 수수료(베팅금에서 차감) - ex) 100 -> 1%

    event Bet(uint indexed gameId, address player, uint spot); // gameId, player, 배정받은 자리
    event EnterFirstPlayer(uint indexed preGameId, uint targetBlockNumber, uint winnerSpot);
    event ClaimReward(uint indexed gameId, address indexed player, uint value);
    event ChangedManagement(address from);

    // 게임 구조체
    struct Game {
        uint targetBlockNumber;
        bytes32 targetBlockhash;
        uint winnerSpot;
        bool rewardClaimed;
        mapping(uint => address) players;
    }

    // 진행 중인 게임 넘버
    Counters.Counter public gameCurrentId;

    // 게임 데이터
    mapping(uint => Game) public games;


    // 유저 참가 게임id 내역
    mapping(address => uint[]) public playerGameId;

    // constructor
    function initialize(address payable _developerWallet, uint _betAmount) public initializer {
        gameCurrentId.increment();
        playerAmount = 4;
        betAmount = _betAmount;
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
        emit ChangedManagement(msg.sender);
    }

    // 수수료 수취 지갑 주소 수정
    function setfeeCollector(address _new) external onlyRole(SET_MANAGEMENT_ROLE) {
        require(_new != address(0));
        implementation = _new;
        emit ChangedManagement(msg.sender);
    }

    // 개발자 수수료 수정
    function setManagementFee(uint _fee) external onlyRole(SET_MANAGEMENT_ROLE) {
        managementFee = _fee;
        emit ChangedManagement(msg.sender);
    }

    // 임시 중지 함수
    function pause() external onlyRole(SET_MANAGEMENT_ROLE) {
        _pause();
    }

    // 임시 중지 해제 함수
    function unpause() external onlyRole(SET_MANAGEMENT_ROLE) {
        _unpause();
    }
}