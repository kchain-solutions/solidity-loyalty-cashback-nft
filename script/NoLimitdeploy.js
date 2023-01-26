async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const CampaignNoLimitFactory = await ethers.getContractFactory("CampaignNoLimitFactory");
    const campaignNoLimitFactory = await CampaignNoLimitFactory.deploy();

    console.log("campaignNoLimitFactory address:", campaignNoLimitFactory.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });