// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';

import '@openzeppelin/contracts/access/Ownable.sol';

contract MonoverseEvent001 is VRFConsumerBaseV2, Ownable {
    event ExecuteLottery(uint256 indexed reqId, uint32 numWords);
    event Winner(bytes32 indexed user, uint256 random);
    event Duplicated(uint256  random);

    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE; // bsc main net
    // address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f; // bsc test net

    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04; // bsc main net
    // bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314; // bsc test net

    //https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/
    uint32 callbackGasLimit = 500_000;

    uint16 requestConfirmations = 3;

    struct WinnerInfo {
        bytes32 userId;
        uint256 randomNumber;
    }

    bytes32[] public eventUsers;
    WinnerInfo[] public winners;
    
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    }


    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        for(uint z=0; z < randomWords.length; z++) {
            uint256 ran = randomWords[z] % eventUsers.length;
            winners.push(WinnerInfo(eventUsers[ran], ran));
            emit Winner(eventUsers[ran], ran);
        }
        
    }

    function getWinnerList() public view returns (WinnerInfo[] memory) {
        return winners;
    }

    function appendUsers(bytes32[] memory users) public onlyOwner {
        for(uint i=0; i<users.length; i++) {
            eventUsers.push(users[i]);
        }
    }

    function getEventUsersLen() external view returns (uint256) {
        return eventUsers.length;
    }

    function getEventUser(uint256 index) external view returns (bytes32) {
        return eventUsers[index];
    }

    function executeLottery(uint32 numWords) external onlyOwner {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit ExecuteLottery(requestId, numWords);
    }

}