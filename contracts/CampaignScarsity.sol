// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ICampaign.sol";

contract CampaignScarsity is ICampaign {
    
    function payWithNft(uint256 tokenId) external payable override {}

    function cashOut() external payable override {}

    function mintNFT() external override returns (uint256) {}

    function changeOrderStatus(uint256 tokenId) external payable override {}

    function getEthPrice(uint256 dollarPrice)
        external
        payable
        override
        returns (uint256)
    {}
}