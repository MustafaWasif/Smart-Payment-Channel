# Smart-Payment-Channel
**Building and Running the application locally**
1) Install a Node.js 14 or higher (16 is recommended)
2) Install dependencies with `npm ci`
3) Run `npx hardhat node`. 
It will start local Ethereum network node. Hardhat will provide you with 20 dummy accounts with 10,000 ethers in each. 
4) On a separate terminal run `npx hardhat run scripts/deploy.js --network localhost`. This will deploy the SimplePaymentChannel smart contract.
5) Setup & Install Remix Daemon to dry run various functions in the smart contract
  * Run `npm install @remix-project/remixd`. 
  * Run `remixd -s .` to start Remix daemon from project directory.
7) Go to https://remix.ethereum.org/ and setup DEPLOY & RUN TRANSACTIONS as follows:
![image](https://user-images.githubusercontent.com/57378302/182563130-a959de72-e9d1-4e8e-b978-86e204f8009d.png)
8) Run `npx hardhat run --network localhost ./scripts/index.js` to get sender's digital signatures which can be used to test out functions that require `signature` as an argument.

