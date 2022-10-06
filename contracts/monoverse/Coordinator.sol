//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;


interface Coordinator {
    function requestRandomness(uint256 randomSize) external returns (uint256);
}
