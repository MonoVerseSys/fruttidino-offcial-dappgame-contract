// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./VRFConsumerBaseV2Upgradable.sol";

contract DinoArcade is Initializable, VRFConsumerBaseV2Upgradable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    using AddressUpgradeable for address payable;
    
    event RequestBet(address indexed user, uint256 indexed requestId, uint256 amount, uint256 betType);
    event BetResult(address indexed user, uint256 indexed requestId, bool indexed isSuccess, uint256 resultAmount, uint256 betType);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");
    uint32 public constant callbackGasLimit = 2000000;
    uint16 public constant requestConfirmations = 3;
    uint32 public constant numWords =  1;

    uint256 public constant LIMIT_BET_COIN = 0.001 ether;
    uint256 public constant LIMIT_BET_FDT = 1 ether;
    uint256 public constant BSC_MAINNET = 56;
    uint256 public constant BSC_TESTNET = 97;

    enum BetType { COIN, FDT }

    struct BetInfo {
        address user;
        uint256 amount;
        BetType betType;
    }
    IERC20 private DinoToken;
    VRFCoordinatorV2Interface private COORDINATOR;
    uint64 private s_subscriptionId;
    
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address private vrfCoordinator;
    bytes32 private keyHash;

    
    mapping(uint256 => BetInfo) private bettingMap; // key requestId, value BetInfo

    receive() external payable {
        emit Deposit(_msgSender(), msg.value);
    }

    function initialize(address deployer, uint64 subscriptionId) public initializer {        
        uint256 id;
        assembly {
            id := chainid()
        }
        require(id == BSC_MAINNET || id == BSC_TESTNET, "Unsupported Network");
        if(id == BSC_MAINNET) {
            COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
            keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
            __VRFConsumerBaseV2_init(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
            DinoToken = IERC20(0x3a599e584075065eAAAc768D75EaEf85c2f2fF64);

        } else if(id == BSC_TESTNET) {
            COORDINATOR = VRFCoordinatorV2Interface(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);
            keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
            __VRFConsumerBaseV2_init(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);
            DinoToken = IERC20(0x474A423Fe3b530894c4dCe0ce61Ea38Ab0E157c7);

        }

        __AccessControl_init();
        s_subscriptionId = subscriptionId;
        _grantRole(DEFAULT_ADMIN_ROLE, deployer);
        _grantRole(MASTER_ROLE, deployer);
    }

    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function _randomRequest(BetInfo memory betInfo) internal {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
            );
        bettingMap[requestId] = BetInfo(betInfo.user, betInfo.amount, betInfo.betType);
        emit RequestBet(betInfo.user, requestId, betInfo.amount, uint256(betInfo.betType));
    }

    
    function betCoin() payable public nonReentrant() {
        require(msg.value >= LIMIT_BET_COIN, "Insufficient minimum batting amount");
        _randomRequest(BetInfo(_msgSender(), msg.value, BetType.COIN));
    }

    function betFdt(uint256 amount) public nonReentrant() {
        require(DinoToken.allowance(_msgSender(), address(this)) >= amount, "Insufficient allowance");
        require(amount >= LIMIT_BET_FDT, "Insufficient minimum batting amount");

        bool result = DinoToken.transferFrom(_msgSender(), address(this), amount);
        require(result, "Token transfer failed");
        _randomRequest(BetInfo(_msgSender(), amount, BetType.FDT));
    }

    function getBetInfo(uint256 requestId) public view returns(BetInfo memory) {
        return bettingMap[requestId];
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        BetInfo memory betInfo = bettingMap[requestId];

        uint256 ran = randomWords[0];
        uint256 range = (ran % 2) + 1; // 1 ~ 2 50%
        bool win = range < 2;
        if(win) {
            uint256 winAmount = betInfo.amount * 197 / 100;
            if(betInfo.betType == BetType.COIN) {    
                payable(betInfo.user).sendValue(winAmount);
                
            } else if(betInfo.betType == BetType.FDT) {
                DinoToken.transfer(betInfo.user, winAmount);
            }
            emit BetResult(betInfo.user, requestId, true, winAmount, uint256(betInfo.betType));

        } else {
            emit BetResult(betInfo.user, requestId, false, 0, uint256(betInfo.betType));
        }
    }

    

    function withdrawCoin(address to, uint256 amount) public onlyRole(MASTER_ROLE) {
        require(to != address(0), "invalid address");
        require(amount <= address(this).balance, "insufficient balance");
        payable(to).sendValue(amount);
        emit Withdrawal(to, amount);
    }

    function addMaster(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "invalid address");
        _grantRole(MASTER_ROLE, account);
    }
    
    function removeMaster(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "invalid address");
        _revokeRole(MASTER_ROLE, account);
    }

}
