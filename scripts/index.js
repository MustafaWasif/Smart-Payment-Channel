const { ethers } = require("hardhat");
// const { library, chainId } = useEthers();
async function main () {
    privateKey='0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'

    // Retrieve accounts from the local node
    const accounts = await ethers.provider.listAccounts();
    // console.log(accounts);

    // Set up an ethers contract, representing our deployed SimplePaymentChannel instance
    const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
    const Payment = await ethers.getContractFactory('SimplePaymentChannel');
    const paymentApp = await Payment.attach(contractAddress);

    const senderAddress = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
    const recipientAddress = '0x71bE63f3384f5fb98995898A86B02Fb2426c5788'; 
    
    amount = 5000000000000000000n;
    const wallet = new ethers.Wallet(privateKey);
    const walletAddress = wallet.address;
    console.log(walletAddress);
    // console.log(wallet.getSigner);
    const message = ethers.utils.solidityKeccak256(
        ['address', 'address', 'uint256'],
        [contractAddress, walletAddress, amount.toString(),],
      );
      console.log(message);
      const arrayifyMessage = ethers.utils.arrayify(message);
      console.log(arrayifyMessage);
      const flatSignature = await wallet.signMessage(arrayifyMessage);
      console.log('Signature: ', flatSignature);

    
    // Call SimplePayment functions
    // const openChannel = await paymentApp.SimplePaymentChannel1(recipientAddress, 500);
    // console.log('OpenChannel Response: ', openChannel);

    // Get Sender's balance
    const getSenderBalance = await paymentApp.getUserBalance(senderAddress);
    console.log('Sender\'s Balance Response: ', getFormattedAmount(getSenderBalance));
  
    // Get Receiver's balance
    // const getRecipientBalance = await paymentApp.getUserBalance(recipientAddress);
    // console.log('Recipient\'s Balance Response: ', getFormattedAmount(getRecipientBalance));
    
    const isValidSig = await paymentApp.isValidSignature(amount, flatSignature);
    console.log('Signature is: ', isValidSig);

    // Withdraw
    // const withdraw = await paymentApp.withdraw(recipientAddress, 1);

}

  // Formats Big Number to more easier, understandable number.
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