// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC1363.sol";

interface FdtToken is IERC20, ERC1363 {
    
}