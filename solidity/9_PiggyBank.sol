pragma solidity ^0.5.0;

contract PiggyBank {

	// State variables:
	address payable owner;		// contract owner's address;
	uint limit;			// piggybank's minimal limit to withdraw;
	uint balance;			// piggybank's deposit balance.

	// Runtime function that allows contract to process inbound messages spending
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Constructor saves the address of the contract owner in a state variable and
	// initializes the limit and the balance.
	constructor(address payable pb_owner, uint pb_limit) public {
		owner = pb_owner;
		limit = pb_limit;
		balance = 0;
	}

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// Modifier that allows public function to be called only from the owners address.
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	// Modifier that allows public function to be called only when the limit is reached.
	modifier checkBalance() {
		require(balance >= limit);
		_;
	}

	// Function that can be called by anyone.
	function deposit() public payable alwaysAccept {
		balance += msg.value;
	}

	// Function that can be called only by the owner after reaching the limit.
	function withdraw() public alwaysAccept onlyOwner checkBalance {
		msg.sender.transfer(balance);
		balance = 0;
	}

}
