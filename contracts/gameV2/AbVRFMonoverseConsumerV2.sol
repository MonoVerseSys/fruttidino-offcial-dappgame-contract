//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "./CoordinatorV2.sol";
import "./ConsumerV2.sol";


abstract contract AbVRFMonoverseConsumerV2 is ConsumerV2  {

    CoordinatorV2 private _coordinator;

    function setVRFCoordinatorAddr(address coordinatorAddr) internal {
        _coordinator = CoordinatorV2(coordinatorAddr);
    }

    function requestRandomness(uint256 randomSize, bytes32 oracleSeedHash) internal returns (uint256) {
        require(address(_coordinator) != address(0), "vrf not initialized");
        return _coordinator.requestRandomness(randomSize, oracleSeedHash);
    }


    function onRandomnessReady(
        uint256 requestId, uint256[] calldata randomness
    ) override external {
        require(
            msg.sender == address(_coordinator),
            "Consumer: Only Coordinator can fulfill"
        );
        fulfillRandomness(requestId, randomness);
    }

    function fulfillRandomness(uint256 requestId, uint256[] calldata randomness)
        internal
        virtual;

    uint256[49] private __gap;
}
