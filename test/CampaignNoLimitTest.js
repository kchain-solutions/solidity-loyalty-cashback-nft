const assert = require('assert');
const { ethers } = require('hardhat');

let tokenContract;

let owner;
let user;

describe("Testing campaign no limit", () => {

    beforeEach(async () => {
        const TOKEN_SUPPLY = 1000;
        const Token = await ethers.getContractFactory("TokenFactory");
        tokenContract = await Token.deploy(TOKEN_SUPPLY, "Apple", "APL");
        const [_owner, _user] = await ethers.getSigners();
        owner = _owner;
        user = _user;
    })

    it(("Create campaign test"), async () => {

    });

});