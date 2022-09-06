// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract DinoArcade2 is VRFConsumerBaseV2, ReentrancyGuard, Context {
    using Address for address payable;
    event RequestBet(address indexed user, uint256 indexed requestId, uint256 amount);
    event BetResult(address indexed user, uint256 indexed requestId, bool indexed isSuccess, uint256 resultAmount);

    
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
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f) {
        uint256 id;
        assembly {
            id := chainid()
        }
        require(id == BSC_MAINNET || id == BSC_TESTNET, "Unsupported Network");
        if(id == BSC_MAINNET) {
            COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
            keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;

        } else if(id == BSC_TESTNET) {
            COORDINATOR = VRFCoordinatorV2Interface(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);
            keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;

        }
        s_subscriptionId = subscriptionId;
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
        bool win = false;
        if(ran % 2 == 0) {
            win = true;
            uint256 winAmount = betInfo.amount * 197 / 100;
            payable(betInfo.user).sendValue(winAmount);
            emit BetResult(betInfo.user, requestId, true, winAmount);
        } else {
            emit BetResult(betInfo.user, requestId, false, 0);
        }
    }

}
