// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./IPriceOracle.sol";

contract PriceOracle is IPriceOracle{

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mumbai Testnet 
     * Aggregator: MATIC/USD
     * Address: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() external view returns (uint256, uint8, uint256) {
        uint8 decimals = priceFeed.decimals();
        (
            , 
            int price,
            ,
            uint timeStamp,
            
        ) = priceFeed.latestRoundData();
        return (uint256(price), decimals, timeStamp);
    }
}