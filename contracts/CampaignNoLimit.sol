// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./UsersNftBalance.sol";
import "./ICampaign.sol";
import "./IPriceOracle.sol";

/*
    Limited offer for infinite NFTs
*/

contract CampaignNoLimitFactory {
    address[] public campaignsCollection;

    function createCampaign(
        IERC20 _token,
        string memory _name,
        string memory _symbol,
        string memory _URI,
        uint256 _productprice,
        uint256 _remaningOffers,
        uint96 _campaignRoyaltiesPerc,
        uint96 _campaignCashbackPerc,
        uint256 _endCampaign
    ) public payable {
        address contractAddress;

        contractAddress = address(
            new CampaignNoLimit(
                msg.sender,
                _token,
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
    ICampaign,
    UsersNftBalance
{
    using Counters for Counters.Counter;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address payable public owner;
    IERC20 token;
    uint256 public adminBalance;
    Counters.Counter private _tokenIds;
    uint256 public productPrice;
    uint96 public royaltiesPerc;
    uint96 public cashbackPerc;
    uint256 public remaningOffers;
    uint256 public mintingPrice;
    uint256 public endCampaign;
    string public URI;

    event Payed(address from, uint256 itemId);
    event Processed(address to, uint256 itemId);

    enum ProcessPhase {
        Minted,
        Payed,
        Processed
    }

    struct NftStatus {
        address campaignOwner;
        address customer;
        address visibilityAdvisor;
        ProcessPhase processPhase;
        string externalResource;
    }

    mapping(uint256 => NftStatus) private nftStatusMapper;

    constructor(
        address _owner,
        IERC20 _token,
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
        token = _token;
        productPrice = _productPrice;
        royaltiesPerc = _royaltiesPerc;
        cashbackPerc = _cashbackPerc;
        remaningOffers = _remaningOffers;
        URI = _URI;
        endCampaign = _endCampaign;
        owner = payable(_owner);
    }

    function mintNFT() public returns (uint256) {
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, URI);
        _addItem(msg.sender, newItemId);

        NftStatus memory nftStatus = NftStatus({
            campaignOwner: owner,
            customer: payable(address(0)),
            visibilityAdvisor: payable(msg.sender),
            processPhase: ProcessPhase.Minted,
            externalResource: ""
        });

        nftStatusMapper[newItemId] = nftStatus;
        _tokenIds.increment();

        return newItemId;
    }

    function payWithNft(uint256 tokenId) public payable {
        NftStatus storage nftStatus = nftStatusMapper[tokenId];
        require(
            nftStatus.processPhase == ProcessPhase.Minted,
            "Token is not valid"
        );
        require(
            token.balanceOf(msg.sender) == productPrice,
            "Not enought funds available"
        );
        require(
            ownerOf(tokenId) == msg.sender,
            "You're not the owner of the Item"
        );
        require(remaningOffers > 0, "The campaign is closed");

        uint256 cashback = (productPrice * cashbackPerc) / 100;
        uint256 royalties = (productPrice * royaltiesPerc) / 100;
        uint256 ownerRavenue = productPrice - cashback - royalties;

        token.approve(address(this), productPrice);

        if (royalties > 0) {
            token.transferFrom(
                msg.sender,
                nftStatus.visibilityAdvisor,
                royalties
            );
        }

        token.transferFrom(msg.sender, nftStatus.campaignOwner, ownerRavenue);

        emit Payed(msg.sender, tokenId);
        remaningOffers = remaningOffers - 1;
        nftStatus.processPhase = ProcessPhase.Payed;
    }

    function transfer(address to, uint256 tokenId)
        public
        payable
        returns (bool)
    {
        NftStatus storage nftStatus = nftStatusMapper[tokenId];
        require(
            nftStatus.processPhase == ProcessPhase.Minted,
            "Not valid NFT to be transfered"
        );
        _transfer(_msgSender(), to, tokenId);
        _moveItem(msg.sender, to, tokenId);
        nftStatus.customer = to;
        return true;
    }

    function setProcessedStatus(string memory externalResource, uint256 tokenId) external payable override {
        require(hasRole(ADMIN_ROLE, msg.sender), "Admin role required");
        NftStatus storage nftStatus = nftStatusMapper[tokenId];
        require(nftStatus.processPhase != ProcessPhase.Minted, "The item is not payed");
        nftStatus.processPhase = ProcessPhase.Processed;
        nftStatus.externalResource = externalResource;
        emit Processed(nftStatus.customer, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
