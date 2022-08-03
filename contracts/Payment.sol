//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SimplePaymentChannel {
    using ECDSA for bytes32;
    address payable public sender;      
    address payable public recipient;
    uint256 public withdrawn;   // How much the recipient has already withdrawn.

    uint256 public closeDuration; // when sender initiates contract close
    uint256 public expiration = 2**256-1; // Initial Contract expiry time

    constructor (address _recipient, uint256 _closeDuration) public payable
    {
        require(msg.sender != _recipient, "Contract deployer needs to be sender");
        require(_closeDuration > 100, "Please provide enough time for recipient to close account"); // Could be some time that is agreed between sender and receiver 
        // require(msg.value > 0, "Please setup contract with some funds.");
        sender = payable(msg.sender);
        recipient = payable(_recipient);
        closeDuration = _closeDuration;
    }

    function getContractAddress() public view returns (address) {
        return address(this);
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint) {
        require(msg.sender == _user, "Balance check restriction: Auth failed");
        return address(_user).balance;
    }

    function withdraw(uint256 amountAuthorized, bytes memory signature) public {
        require(msg.sender == recipient, "Not an authorized recipient for this contract");
    
        require(isValidSignature(amountAuthorized, signature), "Signature invalid");

        // Make sure there's something to withdraw (guards against underflow)
        require(amountAuthorized > withdrawn, "Requested amount was already withdrwan! Please provide latest signature.");
        uint256 amountToWithdraw = amountAuthorized - withdrawn;

        withdrawn += amountToWithdraw;
        payable(msg.sender).transfer(amountToWithdraw);
    }

    // Sender can fund the contract with more balance AFTER contract creation
    receive() external payable {
        require(msg.sender == sender);
    }

    // The recipient can close the channel at any time by presenting a signed
    // amount from the sender. The recipient will be sent that amount, and the
    // remainder will go back to the sender.
    function close(uint256 amount, bytes memory signature) public {
        require(msg.sender == recipient, "Contract can be closed by recipient only");

        require(amount > withdrawn, "Requested amount already withdrawn. Please provide latest signature.");
        uint256 amountToWithdraw = amount - withdrawn;
        require(amountToWithdraw <= address(this).balance, "Money requested is more than Contract balance");
        require(isValidSignature(amountToWithdraw, signature));
        payable(recipient).transfer(amountToWithdraw);

        selfdestruct(sender); //Contract close
    }


    event initiateClosure();

    function initiateClosureBySender() public {
        require(msg.sender == sender, "Recipient cannot initiate closure");
        emit initiateClosure();
        expiration = block.timestamp + closeDuration;
    }

    // If the timeout is reached without the recipient closing the channel, then
    // the ether is released back to the sender.
    function claimTimeout() public {
        require(block.timestamp >= expiration, "Contract has not yet expired");
        selfdestruct(sender);
    }
    
    function isValidSignature(uint256 _amount, bytes memory _signature)
        public
        view
        returns (bool)
    {
        bytes32 messagehash = keccak256(
            abi.encodePacked(address(this), sender, _amount)
        );
        console.log("message hash generated");
        address signer = messagehash.toEthSignedMessageHash().recover(_signature);
        console.log(signer, sender);
        return signer == sender;
    }
}