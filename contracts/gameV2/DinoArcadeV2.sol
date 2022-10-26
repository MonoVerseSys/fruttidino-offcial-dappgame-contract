// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import "./VRFConsumerBaseV2Upgradable.sol";
import "../interface/IERC1363Receiver.sol";
import "../interface/IERC1363Spender.sol";
import "./AbVRFMonoverseConsumerV2.sol";

abstract contract DinoArcadeV2 is Initializable, AbVRFMonoverseConsumerV2, ReentrancyGuardUpgradeable, AccessControlUpgradeable, ERC1363Receiver, ERC1363Spender {
    using AddressUpgradeable for address payable;
    
    // event RequestBet(uint256 indexed requestId);
    event BetResult(address indexed user, uint256 indexed requestId, bool indexed isSuccess, uint256 resultAmount, uint256 betType, uint256 ran);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
     
    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");
    uint32 public constant callbackGasLimit = 2000000; 
    uint16 public constant requestConfirmations = 3;

    uint256 public constant LIMIT_BET_COIN = 0.001 ether;
    uint256 public constant LIMIT_BET_FDT = 1 ether;
    uint256 public constant BSC_MAINNET = 56;
    uint256 public constant BSC_TESTNET = 97;

    enum BetType { COIN, FDT }

    struct BetInfo {
        address user;
        uint256 amount;
        BetType betType;
        uint256[] selected;
    }

    IERC20 private _DinoToken;
    // VRFCoordinatorV2Interface private COORDINATOR;
    uint64 private s_subscriptionId;
    
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address private vrfCoordinator;
    address public dinoTokenAddress;
    
    mapping(uint256 => BetInfo) internal bettingMap; // key requestId, value BetInfo


    function betCoin(uint256[] calldata selected, bytes32 oracleSeedHash) payable public virtual;
    
    receive() external payable {
        emit Deposit(_msgSender(), msg.value);
    }

    function __DinoArcade_init(address deployer) internal onlyInitializing {
        __DinoArcade_init_unchained(deployer);
    }

    function __DinoArcade_init_unchained(address deployer) internal onlyInitializing {
        uint256 id;
        assembly {
            id := chainid()
        }
        require(id == BSC_MAINNET || id == BSC_TESTNET, "Unsupported Network");
        if(id == BSC_MAINNET) {
            dinoTokenAddress = 0x3a599e584075065eAAAc768D75EaEf85c2f2fF64;
            setVRFCoordinatorAddr(0x78B598f203dC9018e40A380B027a421Bcd38A55e);
        } else if(id == BSC_TESTNET) {
            dinoTokenAddress = 0x4E44CF15A450c402E3a532f78182c919D7fE908C;
            setVRFCoordinatorAddr(0x78B598f203dC9018e40A380B027a421Bcd38A55e);
        }

        _DinoToken = IERC20(dinoTokenAddress);
        __AccessControl_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, deployer);
        _grantRole(MASTER_ROLE, deployer);
    }

    function _getDinoToken() internal view returns (IERC20) {
        return _DinoToken;
    }


    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function _randomRequest(address user, uint256 amount, BetType betType, uint256[] memory selected, bytes32 oracleSeedHash) internal {
        uint256 requestId = requestRandomness(1, oracleSeedHash);
        bettingMap[requestId] = BetInfo(user, amount, betType, selected);
        // emit RequestBet(requestId);
    }


    function getBetInfo(uint256 requestId) public view returns(BetInfo memory) {
        return bettingMap[requestId];
    }
    

    function withdrawCoin(address to, uint256 amount) public onlyRole(MASTER_ROLE) {
        require(to != address(0), "invalid address");
        require(amount <= address(this).balance, "insufficient balance");
        payable(to).sendValue(amount);
        emit Withdrawal(to, amount);
    }

    function withdrawFdt(address to, uint256 amount) public onlyRole(MASTER_ROLE) {
        require(to != address(0), "invalid address");
        uint256 balance = _DinoToken.balanceOf(address(this));
        require(balance >= amount, "insufficient balance");
        _DinoToken.transfer(to, balance);
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

    

    
    uint256[44] private __gap;
}
