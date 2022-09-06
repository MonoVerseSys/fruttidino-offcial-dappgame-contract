# Frutti Dino Arcade

[![N|Solid](https://monoverse.io/images/logo.png)](https://monoverse.io)

Chainlink(ORACLE)의 VRF를 이용한 공정한 DAPP

- 50% 승리 확률
- 승리 배당 X 1.97

```
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
```

## deployed address

- bsc testnet : 0x14ed1869b887fE91BF840DCD75013c9f4A814766
- bsc mainent : 0x0