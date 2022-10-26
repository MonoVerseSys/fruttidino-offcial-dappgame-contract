//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;


interface CoordinatorV2 {
    function requestRandomness(uint256 randomSize, bytes32 oracleSeedHash) external returns (uint256);
}
