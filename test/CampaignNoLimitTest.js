const assert = require('assert');
const { ethers } = require('hardhat');

let tokenContract;
let campaignOwnerInstance;
let campaignVisibilityAdvisorInstance;
let campaignCustomerInstance;

let owner;
let customer;
let visibilityAdvisor;

const TOKEN_SUPPLY = 1000 * 10 ^ 18;
const PRODUCT_PRICE = 10 * 10 ^ 18;
const CUSTOMER_BALANCE = 100 * 10 ^ 18;
const REMANING_OFFERS = 99;
const CASHBACK_PERC = 5;
const ROYALTIES_PERC = 9;
const END_CAMPAIGN = 1699977652;

describe("Testing campaign NoLimit", () => {

    beforeEach(async () => {

        const token = await ethers.getContractFactory("TokenFactory");
        tokenContract = await token.deploy(TOKEN_SUPPLY, "Campaign token", "CPT");
        const [_owner, _customer, _visibilityAdvisor] = await ethers.getSigners();
        owner = _owner;
        customer = _customer;
        visibilityAdvisor = _visibilityAdvisor;

        await tokenContract.transfer(customer.address, CUSTOMER_BALANCE);

        const campaignFactory = await ethers.getContractFactory("CampaignNoLimitFactory");
        const campaignFactoryContract = await campaignFactory.deploy();
        const campaignNoLimitAddress = await campaignFactoryContract.createCampaign(
            tokenContract.address,
            "Campaign NoLimit",
            "CPM",
            "campaign.com",
            PRODUCT_PRICE,
            REMANING_OFFERS,
            ROYALTIES_PERC,
            CASHBACK_PERC,
            END_CAMPAIGN
        );

        let campaign = await ethers.getContractFactory("CampaignNoLimit");
        campaignOwnerInstance = await new ethers.Contract(campaignNoLimitAddress, campaign.interface, owner);
        campaignVisibilityAdvisorInstance = await new ethers.Contract(campaignNoLimitAddress, campaign.interface, visibilityAdvisor);
        campaignCustomerInstance = await new ethers.Contract(campaignNoLimitAddress, campaign.interface, customer);

    });

    it("Check users balances", async () => {
        assert.equal(await tokenContract.balanceOf(customer.address), CUSTOMER_BALANCE);
        assert.equal(await tokenContract.balanceOf(owner.address), TOKEN_SUPPLY - CUSTOMER_BALANCE);
    });

    it(("Create campaign test"), async () => {
        assert(campaignOwnerInstance);
        assert(campaignVisibilityAdvisorInstance);
        assert(campaignCustomerInstance);
    });

    it("Minting test", async () => {
        console.log(campaignVisibilityAdvisorInstance);
        let a = await campaignVisibilityAdvisorInstance.mintNFT();
        let b = await campaignVisibilityAdvisorInstance.mintNFT();
        assert.equal(a, 0);
        assert.equal(b, 1);
    });

});