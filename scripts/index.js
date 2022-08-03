const { ethers } = require("hardhat");
const dotenv = require("dotenv");

dotenv.config();

async function main () {
    // Retrieve accounts from the local node
    const accounts = await ethers.provider.listAccounts();
    // console.log(accounts);

    // Set up an ethers contract, representing our deployed SimplePaymentChannel instance
    const contractAddress = process.env.CONTRACT_ADDRESS;   // Adjust based on returned value from deployment script
    const Payment = await ethers.getContractFactory('SimplePaymentChannel');
    const paymentApp = await Payment.attach(contractAddress);

    
    amount = 5000000000000000000n;    // Example amount to transfer in Wei
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY);
    const walletAddress = wallet.address;
    const message = ethers.utils.solidityKeccak256(
        ['address', 'address', 'uint256'],
        [contractAddress, walletAddress, amount.toString(),],
      );
      // console.log(message);
      const arrayifyMessage = ethers.utils.arrayify(message);
      // console.log(arrayifyMessage);
      const flatSignature = await wallet.signMessage(arrayifyMessage);
      console.log('Signature: ', flatSignature); // Get sender's digital signature to be able to test functions in Remix IDE

    
    // Call SimplePayment functions
  
    // Validity of signature
    const isValidSig = await paymentApp.isValidSignature(amount, flatSignature);
    console.log('Signature is: ', isValidSig);

}

  // Formats Big Number in a more readable format.
  function getFormattedAmount(bnAmount) {
    const strAmount = bnAmount.toString();
    var formattedAmount = '';
    if(strAmount !== '10000000000000000000000') {
        formattedAmount = strAmount.substring(0, 4)+"."+strAmount.substring(strAmount.length-18);
    } else{
        formattedAmount = strAmount.substring(0, 5)+"."+strAmount.substring(strAmount.length-18);
    }
    return formattedAmount;
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });