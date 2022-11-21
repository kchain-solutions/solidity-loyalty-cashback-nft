// SPDX-License-Identifier: MIT
/*pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./ICampaign.sol";

contract CampaignScarsityFactory {

    address[] public campaignsCollection;

    function createCampaign(
        string memory name,
        string memory symbol,
        string memory URI,
        uint96 productprice,
        uint256 setupMintingLimit,
        uint96 tokenMaxUsage,
        uint96 campaignRoyaltiesPerc,
        uint96 campaignCashbackPerc
    ) public payable {
        address contractAddress;
        contractAddress = address(
            new CampaignScarsity(
                msg.sender,
                name,
                symbol,
                URI,
                productprice,
                setupMintingLimit,
                tokenMaxUsage,
                campaignRoyaltiesPerc,
                campaignCashbackPerc
            )
        );

        campaignsCollection.push(contractAddress);
    }

    function getCampaigns()
        public
        view
        returns (address[] memory)
    {
        return campaignsCollection;
    }
}


contract CampaignScarsity is ERC721URIStorage, AccessControl, ICampaign {
    using Counters for Counters.Counter;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant VISIBILITY_PROVIDER_ROLE =
        keccak256("VISIBILITY_PROVIDER_ROLE");
    address payable public admin;
    Counters.Counter private _tokenIds;
    string public productName;
    uint256 public productPrice;
    uint96 public royaltiesPerc;
    uint96 public cashbackPerc;
    uint96 public tokenMaxUsages;
    uint256 public mintingLimit;
    uint256 public mintingPrice;
    string uri;

    struct TokenInstance {
        uint256 maxUsages;
        uint256 usageCounter;
    }

    struct SellTokenFlags {
        uint256 price;
        bool payed;
        bool approved;
    }

    mapping(uint256 => address payable) public royaltiesAddressMapper;
    mapping(uint256 => TokenInstance) public tokenInstanceMapper;

    constructor(
        address owner,
        string memory nftName,
        string memory symbol,
        string memory URI,
        uint256 productprice,
        uint256 mintinglimit,
        uint96 tokenMaxUsage,
        uint96 campaignRoyaltiesPerc,
        uint96 campaignCashbackPerc
    ) payable ERC721(nftName, symbol) {
        _setupRole(ADMIN_ROLE, owner);
        _setupRole(MINTER_ROLE, owner);

        productPrice = productprice;
        tokenMaxUsages = tokenMaxUsage;
        royaltiesPerc = campaignRoyaltiesPerc;
        cashbackPerc = campaignCashbackPerc;

        admin = payable(owner);
        mintingLimit = mintinglimit;
        uri = URI;
        mintingPrice =
            productPrice -
            ((productPrice * campaignCashbackPerc) / 100) -
            ((productPrice * campaignRoyaltiesPerc) / 100);
    }

    function mintNFT()
        public payable
        returns (uint256)
    {
        //Need a different permission to mint token
        require(
            msg.value >= mintingPrice,
            "Need to pay the minting price to get the NFT"
        );
        require(
            mintingLimit > _tokenIds.current() + 1,
            "Minted items limit reached"
        );
        uint256 newItemId = _tokenIds.current();

        tokenInstanceMapper[newItemId] = TokenInstance({
            maxUsages: tokenMaxUsages,
            usageCounter: 0
        });

        address payable caller = payable(msg.sender);

        _mint(caller, newItemId);
        _setTokenURI(newItemId, uri);
        royaltiesAddressMapper[newItemId] = caller;
        _tokenIds.increment();
        return newItemId;
    }


    function payWithNft(uint256 tokenId) public payable {
        require(msg.value >= productPrice, "not enought money sent");
        require(
            ownerOf(tokenId) == msg.sender,
            "You're not the owner of the Item"
        );
        TokenInstance storage ti = tokenInstanceMapper[tokenId];
        require(
            ti.usageCounter < ti.maxUsages,
            "The nft is not valid anymore. Maxusages reached"
        );
        //handle the cashback
        ti.usageCounter = ti.usageCounter + 1;

        uint256 cashback = (msg.value * cashbackPerc) / 100;
        uint256 royalties = (msg.value * royaltiesPerc) / 100;

        royaltiesAddressMapper[tokenId].transfer(royalties);
        address payable cashbackAddress = payable(msg.sender);
        cashbackAddress.transfer(cashback);
    }

    function transfer(address recipient, uint256 tokenId)
        public
        payable
        returns (bool)
    {
        _transfer(_msgSender(), recipient, tokenId);
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
}
*/