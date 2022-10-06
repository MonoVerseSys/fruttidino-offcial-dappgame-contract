# Frutti Dino Arcade

[![N|Solid](https://monoverse.io/images/logo.png)](https://monoverse.io)

Chainlink(ORACLE)의 VRF를 이용한 공정한 DAPP

 - 배당
   - 1개 선택 : X7.68
   - 2개 선택 : X3.84
   - 3개 선택 : X2.56
   - 4개 선택 : X1.92
   - 5개 선택 : X1.54
   - 6개 선택 : X1.28
   - 7개 선택 : X1.1
   - 8개 선택 : X0.96

```
    uint256[] _successRate = [7680, 3840, 2560, 1920, 1540, 1280, 1100, 960]
    
    ...

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        BetInfo storage betInfo = bettingMap[requestId];

        uint256 ran = randomWords[0];
        ran = (ran % 8) + 1; // 1 ~ 8
        betInfo.randomNumber = ran;
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
```

## 배팅 종류
 - BNB
 - FDT
   - https://bscscan.com/token/0x3a599e584075065eaaac768d75eaef85c2f2ff64
   - EIP1363을 구현함으로서 배팅 시 Approve 과정이 생략된다. (Token의 transferAndCall을 통해 배팅)


## deployed address

- bsc testnet 
  

- bsc mainent : 0x0