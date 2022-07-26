//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "hardhat/console.sol";

// This is the main building block for smart contracts.
contract SimplePaymentChannel {
    address public sender;     // The account sending payments.
    address public recipient;  // The account receiving the payments.
    uint256 public withdrawn;   // How much the recipient has already withdrawn.

    // How much time the recipient has to respond when the sender initiates
    // channel closure.
    uint256 public closeDuration;
    // When the payment channel closes. Initially effectively infinite.
    uint256 public expiration = 2**256-1;

    function SimplePaymentChannel1(address _recipient, uint256 _closeDuration)
        public
        payable
    {
        // require(msg.value != 0); // for actual dev
        sender = msg.sender;
        recipient = _recipient;
        closeDuration = _closeDuration;
        console.log("This is sender address %s", sender);
        console.log("This is recipients address %s", recipient);
        console.log("Sender Balance %s", sender.balance);
        console.log("Recipient Balance %s", recipient.balance);
    }

    // To make additional deposits to the SC
    function deposit() public payable {
        require(msg.sender == sender);
        console.log("Sender Balance %s", msg.sender.balance);
    }

    function isValidSignature(uint256 amount, bytes32 signature)
        internal
        view
        returns (bool)
    {
        bytes32 message = prefixed(keccak256(abi.encodePacked(amount)));

        // Check that the signature is from the payment sender.
        return recoverSigner(message, signature) == sender;
    }

    function withdraw(uint256 amountAuthorized, bytes32 signature) public {
        require(msg.sender == recipient);

        require(isValidSignature(amountAuthorized, signature));

        // Make sure there's something to withdraw (guards against underflow)
        require(amountAuthorized > withdrawn);
        uint256 amountToWithdraw = amountAuthorized - withdrawn;

        withdrawn += amountToWithdraw;
        payable(msg.sender).transfer(amountToWithdraw); // basically the recipient
        console.log("New Sender Balance %s", sender.balance);
        console.log("Recipient Balance %s", recipient.balance);
        console.log("Also Recipient Balance %s", msg.sender.balance);
        

    }


    // The recipient can close the channel at any time by presenting a signed
    // amount from the sender. The recipient will be sent that amount, and the
    // remainder will go back to the sender.
    function close(uint256 amount, bytes32 signature) public {
        // caller of the function should be the recipient
        require(msg.sender == recipient);
        // ensures signed message is valid
        require(isValidSignature(amount, signature));

        require(amount >= withdrawn);
        console.log("Recipient Balance was %s", msg.sender.balance);
        payable(recipient).transfer(amount - withdrawn);
        console.log("Recipient Balance is %s", msg.sender.balance);
        console.log("Remaining Sender Balance %s", sender.balance);

        selfdestruct(payable(sender));
        console.log("Remaining Sender Balance %s", sender.balance);
    }

    event StartSenderClose();

    // If the sender wants to close channel
    function startSenderClose() public {
        require(msg.sender == sender);
        emit StartSenderClose();
        expiration = block.timestamp + closeDuration;
    }


    // If the timeout is reached without the recipient closing the channel, then
    // the ether is released back to the sender.
    function claimTimeout() public {
        require(block.timestamp >= expiration);
        selfdestruct(payable(sender));
    }

    function splitSignature(bytes32 sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // returns publicKey of signer/sender
    function recoverSigner(bytes32 message, bytes32 sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hash));
    }
}







/*
contract Payment {
    // Some string type variables to identify the token.
    string public name = "My Hardhat Token";
    string public symbol = "MHT";

    // The fixed amount of tokens, stored in an unsigned integer type variable.
    uint256 public totalSupply = 1000000;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account's balance.
    mapping(address => uint256) balances;

    // The Transfer event helps off-chain aplications understand
    // what happens within your contract.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * Contract initialization.
     
    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    /**
     * A function to transfer tokens.
     *
     * The `external` modifier makes a function *only* callable from *outside*
     * the contract.
     
    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false` then the
        // transaction will revert.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify off-chain applications of the transfer.
        emit Transfer(msg.sender, to, amount);
    }

    /**
     * Read only function to retrieve the token balance of a given account.
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}*/