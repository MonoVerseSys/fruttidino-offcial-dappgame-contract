//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "./Coordinator.sol";
import "./Consumer.sol";


abstract contract AbVRFMonoverseConsumer is Consumer  {

    Coordinator private _coordinator;

    function setVRFCoordinatorAddr(address coordinatorAddr) internal {
        _coordinator = Coordinator(coordinatorAddr);
    }

    function requestRandomness(uint256 randomSize) internal returns (uint256) {
        require(address(_coordinator) != address(0), "vrf not initialized");
        return _coordinator.requestRandomness(randomSize);
    }


    function onRandomnessReady(
        uint256 requestId, uint256[] memory randomness
    ) override external {
        require(
            msg.sender == address(_coordinator),
            "Consumer: Only Coordinator can fulfill"
        );
        fulfillRandomness(requestId, randomness);
    }

    function fulfillRandomness(uint256 requestId, uint256[] memory randomness)
        internal
        virtual;

    uint256[49] private __gap;
}
