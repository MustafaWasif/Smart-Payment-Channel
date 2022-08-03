async function main() {
  const recipient = '0x71bE63f3384f5fb98995898A86B02Fb2426c5788';
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  const strBalance = (await deployer.getBalance()).toString();
  const formattedBalance = strBalance.substring(0, 5)+"."+strBalance.substring(strBalance.length-18);
  console.log("Account balance: ", formattedBalance);

  const Payment = await ethers.getContractFactory("SimplePaymentChannel");
  const contract = await Payment.deploy(recipient, 6);

  console.log("Contract address:", contract.address);
}
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });