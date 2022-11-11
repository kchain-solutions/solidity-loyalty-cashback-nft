// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ICampaign {

    function payWithNft(uint256 tokenId) external payable;
    function cashOut() external payable;
    function mintNFT() external returns (uint256);
    function changeOrderStatus(uint256 tokenId) external payable;
    function getEthPrice(uint256 dollarPrice) external payable returns (uint256); 
}