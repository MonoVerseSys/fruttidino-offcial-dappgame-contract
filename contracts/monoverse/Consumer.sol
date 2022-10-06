//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface Consumer {
    function onRandomnessReady(
        uint256 requestId, uint256[] memory randomness
    ) external;
    
}