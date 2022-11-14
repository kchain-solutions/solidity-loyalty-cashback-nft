// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ICampaign {

    function payWithNft(uint256 tokenId) external payable;
    function mintNFT() external returns (uint256);
    function setProcessedStatus(string memory externalResource, uint256 tokenId) external payable;
    function transfer(address recipient, uint256 tokenId) external payable returns (bool);
}