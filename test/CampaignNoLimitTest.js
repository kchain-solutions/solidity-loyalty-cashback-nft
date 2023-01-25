const assert = require('assert');
const { ethers } = require('hardhat');

let tokenContract;
let campaignFactoryContract;

let owner;
let customer;
let visibilityAdvisor;

const TOKEN_SUPPLY = ethers.utils.parseUnits("1000", 18);
const PRODUCT_PRICE = ethers.utils.parseUnits("1", 18);
const CUSTOMER_BALANCE = ethers.utils.parseUnits("100", 18);
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

        //const campaignFactory = await ethers.getContractFactory("CampaignNoLimitFactory");
        const campaignFactory = await ethers.getContractFactory("CampaignNoLimit");
        campaignFactoryContract = await campaignFactory.deploy(
            owner.address,
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

    });

    it("Check users balances", async () => {
        let ownerBalance = ethers.utils.formatUnits(await tokenContract.balanceOf(owner.address), 18);
        let userBalance = ethers.utils.formatUnits(await tokenContract.balanceOf(customer.address), 18);
        let tsupply = ethers.utils.formatUnits(TOKEN_SUPPLY, 18);
        let cbalance = ethers.utils.formatUnits(CUSTOMER_BALANCE, 18);
        assert.equal(userBalance, cbalance);
        assert.equal(ownerBalance, tsupply - cbalance);
        assert(userBalance > ethers.utils.formatUnits(PRODUCT_PRICE, 18));
    });

    it(("Create campaign test"), async () => {
        assert(campaignFactoryContract);
    });

    it("Minting test", async () => {
        vcontract = await campaignFactoryContract.connect(visibilityAdvisor);
        await vcontract.mintNFT();
        let nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);
        assert.equal(nftStatusMapper.visibilityAdvisor, visibilityAdvisor.address);
    });

    it("Transfer token", async () => {
        let vcontract = await campaignFactoryContract.connect(visibilityAdvisor);
        await vcontract.mintNFT();
        await vcontract.transfer(customer.address, 0);
        let nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);
        assert.equal(nftStatusMapper.visibilityAdvisor, visibilityAdvisor.address);
        assert.equal(nftStatusMapper.customer, customer.address);
    });

    it("Pay with token", async () => {
        let vcontract = await campaignFactoryContract.connect(visibilityAdvisor);
        await vcontract.mintNFT();
        await vcontract.transfer(customer.address, 0);
        let nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);

        let ccontract = await campaignFactoryContract.connect(customer);

        let ctoken = await tokenContract.connect(customer);
        await ctoken.approve(ccontract.address, CUSTOMER_BALANCE)
        await ccontract.payWithNFT(0);

        nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);

        assert.equal(nftStatusMapper.visibilityAdvisor, visibilityAdvisor.address);
        assert.equal(nftStatusMapper.customer, customer.address);
        assert.equal(nftStatusMapper.processPhase, 1);
        let customer_balance = await ctoken.balanceOf(customer.address);

        let cashback = PRODUCT_PRICE.mul(ethers.BigNumber.from(CASHBACK_PERC)).div(ethers.BigNumber.from("100"));
        let expected = CUSTOMER_BALANCE.sub(PRODUCT_PRICE).add(cashback);

        let royalties = ethers.utils.formatUnits(PRODUCT_PRICE.mul(ethers.BigNumber.from(ROYALTIES_PERC)).div(ethers.BigNumber.from("100")), 18);
        let visibilityAdvisorBalance = ethers.utils.formatUnits(await ctoken.balanceOf(visibilityAdvisor.address), 18);
        assert.equal(ethers.utils.formatUnits(customer_balance, 18), ethers.utils.formatUnits(CUSTOMER_BALANCE.sub(PRODUCT_PRICE).add(cashback), 18));
        assert.equal(visibilityAdvisorBalance, royalties);
    });

    it("Set payment processed with token", async () => {
        let vcontract = await campaignFactoryContract.connect(visibilityAdvisor);
        await vcontract.mintNFT();
        await vcontract.transfer(customer.address, 0);
        let nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);

        let ccontract = await campaignFactoryContract.connect(customer);

        let ctoken = await tokenContract.connect(customer);
        await ctoken.approve(ccontract.address, CUSTOMER_BALANCE)
        await ccontract.payWithNFT(0);

        nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);

        let owner_balance = await ctoken.balanceOf(owner.address);


        let cashback = PRODUCT_PRICE.mul(ethers.BigNumber.from(CASHBACK_PERC)).div(ethers.BigNumber.from("100"));
        let royalties = PRODUCT_PRICE.mul(ethers.BigNumber.from(ROYALTIES_PERC)).div(ethers.BigNumber.from("100"));

        let expected = PRODUCT_PRICE.sub(cashback).sub(royalties);

        assert.equal(ethers.utils.formatUnits(owner_balance.sub(TOKEN_SUPPLY.sub(CUSTOMER_BALANCE)), 18), ethers.utils.formatUnits(expected, 18));

        let ocontract = campaignFactoryContract.connect(owner);

        let externalResource = "rs.com"
        await ocontract.setProcessedStatus(externalResource, 0);
        nftStatusMapper = await campaignFactoryContract.nftStatusMapper(0);

        assert(nftStatusMapper.processPhase, 2);
        assert(nftStatusMapper.externalResource, externalResource);
    });

});