pragma solidity ^0.5.0;

// This sample demonstrates usage of selfdestruct function.

contract Kamikaze {

	// Modifier that allows to accept inbound message only if it was signed with owner's public
	// key.
	modifier checkOwnerAndAccept {
		require(owners_pubkey == msg.pubkey()); // Runtime function that obtains sender's public key.
		tvm.accept(); 	// Runtime function that allows contract to process inbound messages spending
				// it's own resources (it's necessary if contract should process all inbound messages,
				// not only those that carry value with them).
		_;
	}

	// State variable storing the number of times fallback function was called.
	uint fallbackCounter = 0;

	// State variable storing the owner's public key.
	uint256 owners_pubkey;

	// Constructor saves the owner's public key in the state variable.
	constructor() public {
		owners_pubkey = tvm.pubkey(); // Runctime function that obtains contract owner's public key.
	}

	// Due to the modifier checkOwnerAndAccept function sendAllMoney can be
	// called only by the owner of the contract.
	function sendAllMoney(address payable dest_addr) public checkOwnerAndAccept {
		selfdestruct(dest_addr);
	}

	// Fallback function.
	function() external payable {
		fallbackCounter++;
	}
}
