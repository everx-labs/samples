pragma solidity ^0.5.0;

// This sample demonstrates usage of selfdestruct function.

contract Kamikaze {

	// Runtime functions
	function tvm_accept() private pure {}
	function tvm_sender_pubkey() private view returns (uint256) {}
	function tvm_my_public_key() private pure returns (uint256) {}

	// Modifier that allows to accept inbound message only if it was signed with owner's public
	// key.
	modifier checkOwnerAndAccept {
		require(owners_pubkey == tvm_sender_pubkey());
		tvm_accept(); _;
	}

	uint m_counter;

	// State variable storing the owner's public key.
	uint256 owners_pubkey;

	// Constructor saves the owner's public key in a state variable.
	constructor() public {
		owners_pubkey = tvm_my_public_key();
	}

	// Due to the modifier checkOwnerAndAccept function sendAllMoney can be 
	// called only by the owner of the contract.
	function sendAllMoney(address payable dest_addr) public checkOwnerAndAccept {
		selfdestruct(dest_addr);
	}

	function() public payable {
		m_counter++;
	}
}
