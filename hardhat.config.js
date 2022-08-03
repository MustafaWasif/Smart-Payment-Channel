/** @type import('hardhat/config').HardhatUserConfig */
require('@nomicfoundation/hardhat-toolbox');
const ALCHEMY_API_KEY = "iDaLE2jljlaGlga-12kYUUiwCCxdBxCU";
const GOERLI_PRIVATE_KEY = "ebee5cdc00935fb07fe0d0ce42345ec45ade63f4efec0fabefc5fec030d31317";

const PRE_FUNDED_PRIVATE_KEY_10 = "0xf214f2b2cd398c806f84e317254e0f0b801d0643303237d97a22a48e01628897";
const PRE_FUNDED_PRIVATE_KEY_11 = "0x701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82";
// const hexaString = '#' + ('00000' + PRE_FUNDED_PRIVATE_KEY_11.toString().toUpperCase()).slice(-6);

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      chainId: 31337, // Chain ID should match the hardhat network's chainid
      // accounts: [`${PRE_FUNDED_PRIVATE_KEY_10}`, `${PRE_FUNDED_PRIVATE_KEY_11}`],
      allowUnlimitedContractSize: true
    },
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  }

};
