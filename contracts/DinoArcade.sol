// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./VRFConsumerBaseV2Upgradable.sol";

contract DinoArcade is Initializable, VRFConsumerBaseV2Upgradable, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    using AddressUpgradeable for address payable;
    event RequestBet(address indexed user, uint256 indexed requestId, uint256 amount);
    event BetResult(address indexed user, uint256 indexed requestId, bool indexed isSuccess, uint256 resultAmount, uint256 randomValue);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");

    uint32 constant callbackGasLimit = 2000000;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords =  1;

    uint256 constant LIMIT_BET = 0.01 ether;
    uint256 constant BSC_MAINNET = 56;
    uint256 constant BSC_TESTNET = 97;
    struct BetInfo {
        address user;
        uint256 amount;
    }

    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    // Goerli coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator;

    // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations

    bytes32 keyHash;

    

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

        } else if(id == BSC_TESTNET) {
            COORDINATOR = VRFCoordinatorV2Interface(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);
            keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
            __VRFConsumerBaseV2_init(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);

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

    
    function betCoin() payable public nonReentrant() {
        require(msg.value >= LIMIT_BET, "Insufficient minimum batting amount");
        
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
            );
        bettingMap[requestId] = BetInfo(_msgSender(), msg.value);
        emit RequestBet(_msgSender(), requestId, msg.value);
            
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
        bool win = false;
        if(range == 1) {
            win = true;
            uint256 winAmount = betInfo.amount * 197 / 100;
            payable(betInfo.user).sendValue(winAmount);
            emit BetResult(betInfo.user, requestId, true, winAmount, ran);
        } else {
            emit BetResult(betInfo.user, requestId, false, 0, ran);
        }
    }

    function withdrawCoin(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount <= address(this).balance, "insufficient balance");
        payable(to).sendValue(amount);
        emit Withdrawal(to, amount);
    }

    function addMaster(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        
        _grantRole(MASTER_ROLE, account);
    }
    
    function removeMaster(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MASTER_ROLE, account);
    }

}
