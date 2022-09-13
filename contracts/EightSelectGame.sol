// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./DinoArcade.sol";

contract EightSelectGame is Initializable, DinoArcade {
    uint256[] private _successRate;
    using AddressUpgradeable for address payable;

    function initialize(address deployer, uint64 subscriptionId) public initializer {
        __DinoArcade_init(deployer, subscriptionId);
        _successRate = [
            7680, 3840, 2560, 1920, 1540, 1280, 1100, 960
        ];
    }

    function betCoin(uint256[] memory selected) payable public override nonReentrant() {
        require(selected.length >= 1 && selected.length <= 8, "Input value is not valid");
        require(msg.value >= LIMIT_BET_COIN, "Insufficient minimum betting amount");
        _randomRequest(BetInfo(_msgSender(), msg.value, BetType.COIN, selected));
    }

    function betFdt(uint256 amount, uint256[] memory selected) public override nonReentrant() {
        require(selected.length >= 1 && selected.length <= 8, "Input value is not valid");
        require(_getDinoToken().allowance(_msgSender(), address(this)) >= amount, "Insufficient allowance");
        require(amount >= LIMIT_BET_FDT, "Insufficient minimum betting amount");

        bool result = _getDinoToken().transferFrom(_msgSender(), address(this), amount);
        require(result, "Token transfer failed");
        _randomRequest(BetInfo(_msgSender(), amount, BetType.FDT, selected));
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        BetInfo memory betInfo = getBetInfo(requestId);

        uint256 ran = randomWords[0];
        ran = (ran % 8) + 1; // 1 ~ 8
        uint256 selectedCount = betInfo.selected.length;
        bool win = false;
        for(uint256 i = 0; i < selectedCount; i++) {
            if(ran == betInfo.selected[i]) {
                win = true;
                break;
            }
        }

        if(win) {
            uint256 winAmount = betInfo.amount * _successRate[selectedCount - 1] / 1000;
            if(betInfo.betType == BetType.COIN) {    
                payable(betInfo.user).sendValue(winAmount);
                
            } else if(betInfo.betType == BetType.FDT) {
                _getDinoToken().transfer(betInfo.user, winAmount);
            }
            emit BetResult(betInfo.user, requestId, true, winAmount, uint256(betInfo.betType));

        } else {
            emit BetResult(betInfo.user, requestId, false, 0, uint256(betInfo.betType));
        }
    }

}