const { expect } = require("chai");

describe("Payment contract", function () {

  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners(); // get list of accounts and keep first one

    const Token = await ethers.getContractFactory("Payment"); // gets contract for deployment

    const hardhatToken = await Token.deploy(); // To deploy smart contract

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});