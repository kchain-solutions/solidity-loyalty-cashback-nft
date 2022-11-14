// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IPriceOracle{
    function getLatestPrice() external view returns (uint256, uint8, uint256);
}