// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ICampaign {

    function payWithNFT(uint256 tokenId) external;
    function mintNFT() external returns (uint256);
    function setProcessedStatus(string memory externalResource, uint256 tokenId) external;
    function transfer(address recipient, uint256 tokenId) external returns (bool);
}