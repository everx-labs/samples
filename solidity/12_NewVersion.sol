pragma solidity ^0.5.0;

// Type TvmCell is only supported in the new experimental ABI encoder.
pragma experimental ABIEncoderV2;

contract PiggyBank {

	// Struct that is used to process TVM internal type Cell.
	struct TvmCell {
		uint _;
	}

	// State variables:
	address payable owner;		// contract owner's address;
	uint limit;			// piggybank's minimal limit to withdraw;
	uint balance;			// piggybank's deposit balance;
	uint version = 1;		// version of the PiggyBank.

	// Runtime function that allows contract to process inbound messages spending
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Runtime function that creates an output action that would change this
	// smart contract code to that given by cell newcode.
	function tvm_setcode(TvmCell memory newcode) private pure {}

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// Modifier that allows public function to be called only from the owners address.
	modifier checkOwnerAndAccept {
		require(msg.sender == owner);
		tvm_accept();
		_;
	}

	// Modifier that allows public function to be called only when the limit is reached.
	modifier checkBalance() {
		require(balance >= limit);
		_;
	}

	// Constructor saves the address of the contract owner in a state variable and
	// initializes the limit and the balance.
	constructor(address payable pb_owner, uint pb_limit) public {
		owner = pb_owner;
		limit = pb_limit;
		balance = 0;
	}

	// Function that can be called by anyone.
	function deposit() public payable alwaysAccept {
		balance += msg.value;
	}

	// Function to change the PiggyBank limit that can be called only by the owner
	function setLimit(uint newLimit) public payable checkOwnerAndAccept {
		limit = newLimit;
	}

	// Function that can be called only by the owner after reaching the limit.
	function withdraw() public checkBalance checkOwnerAndAccept {
		msg.sender.transfer(balance);
		balance = 0;
	}

	// Function that changes the code of current contract.
	function setCode(TvmCell memory newcode) public pure alwaysAccept {
		tvm_setcode(newcode);
	}

	// After upgrade caused by calling setCode function we may need to do some actions.
	// We can add them into this function.
	function after_code_upgrade() public {
		version = 2;
	}

}
