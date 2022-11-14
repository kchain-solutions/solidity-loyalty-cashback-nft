// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ICampaign.sol";

contract CampaignScarsity is ICampaign {
    function payWithNft(uint256 tokenId) external payable override {}

    function mintNFT() external override returns (uint256) {}

    function setProcessedStatus(string memory externalResource, uint256 tokenId)
        external
        payable
        override
    {}

    function transfer(address recipient, uint256 tokenId)
        external
        payable
        override
        returns (bool)
    {}
}