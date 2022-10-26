//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./CoordinatorV2.sol";
import "./ConsumerV2.sol";

contract VRFMonoverseCoordinatorV2 is Initializable, CoordinatorV2, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    bytes32 private constant MASTER_ROLE = keccak256("MASTER_ROLE");
    bytes32 private constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    event AddConsumer(address indexed consumer);
    event RemoveConsumer(address indexed consumer);

    event RandomnessFulfilled(
        uint256 requestId
    );

    event Request(
        address indexed consumer,
        uint256 requestId,
        bytes32 seedHash
    );

    struct RequestContent {
        address consumer;
        uint256 ranSize;
        bytes32 seedHash;
    }

    struct ResultContent {
        bytes32 seed;
        uint256[] randomNumbers;
    }

    mapping(address => uint256) private _consumers;
    mapping(uint256 => RequestContent) private _reqContent;
    mapping(uint256 => ResultContent) private _restContent;

    function initialize(address deployer) public initializer {
        __AccessControl_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, deployer);
        _grantRole(MASTER_ROLE, deployer);
        
    }



    function requestRandomness(uint256 randomSize, bytes32 oracleSeedHash) external override nonReentrant returns (uint256)  {
        uint256 preNonce = _consumers[msg.sender];
        require(preNonce > 0, "non-existent consumer");
        uint256 nonce = preNonce + 1;
        uint256 requestId = uint256(keccak256(abi.encode(msg.sender, nonce, block.timestamp)));
        
        _reqContent[requestId] = RequestContent(msg.sender, randomSize, oracleSeedHash);
        _consumers[msg.sender] = nonce;
        emit Request(msg.sender, requestId, oracleSeedHash);
        return requestId;
    }

    function addConsumer(address consumer) external nonReentrant onlyRole(MASTER_ROLE) {
        uint256 nonce = _consumers[consumer];
        require(nonce == 0, "Already exists");
        _consumers[consumer] = 1;
        emit AddConsumer(consumer);
    }

    function removeConsumer(address consumer) external nonReentrant onlyRole(MASTER_ROLE) {
        uint256 nonce = _consumers[consumer];
        require(nonce > 0, "non-existent consumer");
        delete _consumers[consumer];
        emit RemoveConsumer(consumer);
    }

    function addOracle(address oracle) external nonReentrant onlyRole(MASTER_ROLE) {
        _grantRole(ORACLE_ROLE, oracle);
    }

    function removeOracle(address oracle) external nonReentrant onlyRole(MASTER_ROLE) {
        _revokeRole(ORACLE_ROLE, oracle);
    }


    function getRandomInfo(uint256 requestId) public view returns(RequestContent memory, ResultContent memory, uint256[] memory) {
        RequestContent memory req = _reqContent[requestId];
        ResultContent memory rest = _restContent[requestId];
        uint256[] memory randomNumbers = new uint256[](req.ranSize);
        for (uint256 i = 0; i < req.ranSize; i++) {
            randomNumbers[i] = uint256(keccak256(abi.encode(requestId, rest.seed, i)));
        }
        return (req, rest, randomNumbers);
    }

    function fulfillRandomWords(
        bytes32 seed,
        uint256 requestId
    ) external nonReentrant onlyRole(ORACLE_ROLE) {
        RequestContent memory req = _reqContent[requestId];
        
        require(req.consumer != address(0), "not found requestId");
        require(req.seedHash == keccak256(abi.encode(seed)), "seed mismatch");

        uint256[] memory randomNumbers = new uint256[](req.ranSize);
        for (uint256 i = 0; i < req.ranSize; i++) {
            randomNumbers[i] = uint256(keccak256(abi.encode(requestId, seed, i)));
        }
        ConsumerV2 consumer = ConsumerV2(req.consumer);
        consumer.onRandomnessReady(requestId, randomNumbers);
        _restContent[requestId] = ResultContent(seed, randomNumbers);
        emit RandomnessFulfilled(requestId);
    }

}
