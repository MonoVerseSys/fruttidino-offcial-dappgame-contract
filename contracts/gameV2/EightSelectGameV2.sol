// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./DinoArcadeV2.sol";

contract EightSelectGameV2 is Initializable, DinoArcadeV2 {
    using AddressUpgradeable for address payable;
    uint256[] private _successRate;

    function initialize(address deployer) public initializer {
        __DinoArcade_init(deployer);
        _successRate = [
            7680, 3840, 2560, 1920, 1540, 1280, 1100, 960
        ];
    }

    function betCoin(uint256[] calldata selected, bytes32 oracleSeedHash) payable public override nonReentrant() {
        require(selected.length >= 1 && selected.length <= 8, "Input value is not valid");
        require(msg.value >= LIMIT_BET_COIN, "Insufficient minimum betting amount");
        _randomRequest(_msgSender(), msg.value, BetType.COIN, selected, oracleSeedHash);

    }

    function _betFdt(address sender, uint256 amount, uint256[] memory selected, bytes32 oracleSeedHash) internal  {
        require(selected.length >= 1 && selected.length <= 8, "Input value is not valid");
        require(amount >= LIMIT_BET_FDT, "Insufficient minimum betting amount");
        _randomRequest(sender, amount, BetType.FDT, selected, oracleSeedHash);
    }

    function onTransferReceived(address operator, address from, uint256 value, bytes calldata data) external override nonReentrant() returns (bytes4) {
        if(data.length > 0 && _msgSender() == dinoTokenAddress) {
            (uint256[] memory selected, bytes32 oracleSeedHash) = abi.decode(data, (uint256[], bytes32));
            _betFdt(from, value, selected, oracleSeedHash);
        }
        return this.onTransferReceived.selector;
    }

    function onApprovalReceived(address sender, uint256 amount, bytes memory data) external override nonReentrant() returns (bytes4) {
        return this.onApprovalReceived.selector;
    }

    function fulfillRandomness(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override  {
        BetInfo memory betInfo = bettingMap[requestId];

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
            emit BetResult(betInfo.user, requestId, true, winAmount, uint256(betInfo.betType), ran);

        } else {
            emit BetResult(betInfo.user, requestId, false, 0, uint256(betInfo.betType), ran);
        }
    }
}