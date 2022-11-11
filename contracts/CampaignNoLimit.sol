// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./UsersNftBalance.sol";
import "./ICampaign.sol";

contract CampaignNoLimitFactory {
    address[] public campaignsCollection;

    function createCampaign(
        string memory _name,
        string memory _symbol,
        string memory _URI,
        uint96 _productprice,
        uint256 _remaningOffers,
        uint96 _campaignRoyaltiesPerc,
        uint96 _campaignCashbackPerc,
        uint256 _endCampaign
    ) public payable {
        address contractAddress;

        contractAddress = address(
            new CampaignNoLimit(
                msg.sender,
                _name,
                _symbol,
                _URI,
                _productprice,
                _remaningOffers,
                _campaignRoyaltiesPerc,
                _campaignCashbackPerc,
                _endCampaign
            )
        );
        campaignsCollection.push(contractAddress);
    }
}

contract CampaignNoLimit is
    ERC721URIStorage,
    AccessControl,
    UsersNftBalance,
    ICampaign
{
    //Limited offer for infinite NFT
    using Counters for Counters.Counter;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address payable public owner;
    uint256 public adminBalance;
    Counters.Counter private _tokenIds;
    uint256 public productPrice;
    uint96 public royaltiesPerc;
    uint96 public cashbackPerc;
    uint256 public remaningOffers;
    uint256 public mintingPrice;
    uint256 public endCampaign;
    string public URI;

    enum ProcessPhase{
        Minted,
        Payed,
        Processed
    }

    struct NftStatus {
        address payable contractOwner;
        address payable nftOwner;
        address payable nftMinter;
        ProcessPhase processPhase;
    }

    mapping(uint256 => address payable) public royaltiesAddressMapper;
    mapping(uint256 => bool) public tokenIsUsed;
    

    uint256 public mintingLimit;

    constructor(
        address _owner,
        string memory _nftName,
        string memory _symbol,
        string memory _URI,
        uint256 _productPrice,
        uint256 _remaningOffers,
        uint96 _royaltiesPerc,
        uint96 _cashbackPerc,
        uint256 _endCampaign
    ) payable ERC721(_nftName, _symbol) {
        _setupRole(ADMIN_ROLE, _owner);
        productPrice = _productPrice;
        royaltiesPerc = _royaltiesPerc;
        cashbackPerc = _cashbackPerc;
        remaningOffers = _remaningOffers;
        URI = _URI;
        endCampaign = _endCampaign;
        owner = payable(_owner);
    }

    function mintNFT() public returns (uint256) {
        //Require the campaign is still active
        uint256 newItemId = _tokenIds.current();
        address payable NftOwner = payable(msg.sender);

        _mint(NftOwner, newItemId);
        _setTokenURI(newItemId, URI);
        _addItem(msg.sender, newItemId);
        royaltiesAddressMapper[newItemId] = NftOwner;
        tokenIsUsed[newItemId] = false;
        _tokenIds.increment();

        return newItemId;
    }

    function cashOut() public payable {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only ADMIN can do cashout");
        require(adminBalance > 0, "Not ETH available to cashOut");
        owner.transfer(adminBalance);
    }


    function payWithNft(uint256 tokenId) public payable {
        //Require the campaign is active
        require(msg.value == productPrice, "Pay the product price amount");
        require(
            ownerOf(tokenId) == msg.sender,
            "You're not the owner of the Item"
        );
        require(tokenIsUsed[tokenId] == false, "Token is not valid anymore");
        // When the remaningOffers reach zero the campaign is closed
        require(remaningOffers >= 0, "The campaign is closed");

        uint256 cashback = (msg.value * cashbackPerc) / 100;
        uint256 royalties = (msg.value * royaltiesPerc) / 100;
        uint256 adminRavenue = msg.value - cashback - royalties;

        if (royalties > 0) royaltiesAddressMapper[tokenId].transfer(royalties);
        address payable cashbackAddress = payable(msg.sender);
        remaningOffers = remaningOffers - 1;
        if (cashback > 0) cashbackAddress.transfer(cashback);
        if (adminRavenue > 0) owner.transfer(adminRavenue);

        tokenIsUsed[tokenId] = true;
        adminBalance = adminBalance + msg.value - cashback - royalties;
        _putInvalid(msg.sender, tokenId);
    }

    function transfer(address recipient, uint256 tokenId)
        public
        payable
        returns (bool)
    {
        _transfer(_msgSender(), recipient, tokenId);
        _moveItem(msg.sender, tokenId, recipient);
        return true;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function changeOrderStatus(uint256 tokenId) external payable override {}

    function getEthPrice(uint256 dollarPrice)
        external
        payable
        override
        returns (uint256)
    {}
}
