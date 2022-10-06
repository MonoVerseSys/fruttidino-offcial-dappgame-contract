//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../lib/VRF.sol";
import "./Coordinator.sol";
import "./Consumer.sol";


contract VRFMonoverseCoordinator is Initializable, Coordinator, ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    bytes32 private constant MASTER_ROLE = keccak256("MASTER_ROLE");
    event AddConsumer(address indexed consumer);
    event RemoveConsumer(address indexed consumer);
    event RegisterOracle(bytes32 indexed keyHash, address indexed oracle);
    event RemoveOracle(bytes32 indexed keyHash, address indexed oracle);
    event RandomnessFulfilled(
        uint256 requestId,
        uint256[] randomness,
        uint256[4] _proof,
        bytes _message
    );

    struct RequestContent {
        address consumer;
        uint256 nonce;
        uint256 ranSize;
        uint256 blockNumber;
    } 

    mapping(address => uint256) private _consumers;
    mapping(bytes32 => address) private _oracles;
    mapping(uint256 => RequestContent) private _reqContent;

    function initialize(address deployer) public initializer {
        __AccessControl_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, deployer);
        _grantRole(MASTER_ROLE, deployer);
    }

    function registerOracle(address oracle, uint256[2] memory publicKey) external nonReentrant onlyRole(MASTER_ROLE) {
        bytes32 keyHash = hashOfKey(publicKey);
        _oracles[keyHash] = oracle;
        emit RegisterOracle(keyHash, oracle);
    }

    function removeOracle(uint256[2] memory publicKey) external nonReentrant onlyRole(MASTER_ROLE) {
        bytes32 keyHash = hashOfKey(publicKey);
        address oracle = _oracles[keyHash];
        require(oracle != address(0), "not found");
        delete _oracles[keyHash];
        emit RemoveOracle(keyHash, oracle);
    }

    function requestRandomness(uint256 randomSize) external override nonReentrant returns (uint256)  {
        uint256 preNonce = _consumers[msg.sender];
        require(preNonce > 0, "non-existent consumer");
        uint256 nonce = preNonce + 1;
        uint256 requestId = uint256(keccak256(abi.encode(msg.sender, nonce)));
        _reqContent[requestId] = RequestContent(msg.sender, nonce, randomSize, block.number);
        _consumers[msg.sender] = nonce;

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


    function hashOfKey(uint256[2] memory publicKey) public pure returns (bytes32) {
        return keccak256(abi.encode(publicKey));
    }

    function fulfillRandomWords(
        uint256[2] memory publicKey,
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents,
        uint256 requestId
    ) external nonReentrant {
        address oracle = _oracles[hashOfKey(publicKey)];
        require(oracle != address(0), "no auth");
        RequestContent memory req = _reqContent[requestId];
        require(req.consumer != address(0), "not found requestId");
        bool isValid = VRF.fastVerify(
                publicKey,
                proof,
                message,
                uPoint,
                vComponents
            );
        require(isValid, "Consumer: Proof is not valid");
        
        uint256 randomness = uint256(VRF.gammaToHash(proof[0], proof[1]));
        uint256[] memory randomNumbers = new uint256[](req.ranSize);
         for (uint256 i = 0; i < req.ranSize; i++) {
            randomNumbers[i] = uint256(keccak256(abi.encode(randomness, i)));
        }
        Consumer consumer = Consumer(req.consumer);
        consumer.onRandomnessReady(requestId, randomNumbers);
        emit RandomnessFulfilled(requestId, randomNumbers, proof, message);

    }

}
