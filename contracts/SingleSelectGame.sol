// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "./DinoArcade.sol";

contract SingleSelectGame is Initializable, DinoArcade {
    using AddressUpgradeable for address payable;
    uint256 private _successRate;

    function initialize(address deployer, uint64 subscriptionId) public initializer {        
        __DinoArcade_init(deployer, subscriptionId);
        _successRate = 1920;
    }

    function betCoin(uint256[] memory selected) payable public override nonReentrant() {
        require(selected.length == 1, "Input value is not valid");
        require(msg.value >= LIMIT_BET_COIN, "Insufficient minimum betting amount");
        _randomRequest(BetInfo(_msgSender(), msg.value, BetType.COIN, selected, 0));
    }

    function _betFdt(address sender, uint256 amount, uint256[] memory selected) internal {
        require(selected.length == 1, "Input value is not valid");
        require(amount >= LIMIT_BET_FDT, "Insufficient minimum betting amount");
        _randomRequest(BetInfo(sender, amount, BetType.FDT, selected, 0));
    }


    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external override nonReentrant() returns (bytes4) {
        if(data.length > 0 && _msgSender() == dinoTokenAddress) {
            (uint256[] memory selected) = abi.decode(data, (uint256[]));
            _betFdt(from, value, selected);
        }
        return this.onTransferReceived.selector;
    }

    function onApprovalReceived(address sender, uint256 amount, bytes memory data) external override nonReentrant() returns (bytes4) {
        return this.onApprovalReceived.selector;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        BetInfo storage betInfo = bettingMap[requestId];
        uint256 ran = randomWords[0];
        ran = (ran % 2) + 1; // 1 ~ 2
        betInfo.randomNumber = ran;

        if(betInfo.selected[0] == ran) { // win
            uint256 winAmount = betInfo.amount * _successRate / 1000;
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