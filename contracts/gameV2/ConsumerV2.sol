//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface ConsumerV2 {
    function onRandomnessReady(
        uint256 requestId, uint256[] calldata randomness
    ) external;
    
}