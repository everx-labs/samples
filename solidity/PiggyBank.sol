pragma solidity ^0.5.0;

contract PiggyBank {

	// state variables: 
	address payable owner;		// contract owner's address
	uint limit;			// piggybank's minimal limit to withdraw
	uint balance;			// piggybank's deposit balance
	
	// runtime function that allows contract to process external messages, which bring 
	// no value with themselves.
	function tvm_accept() private pure {}

	// constructor saves the address of the contract owner in a state variable and
	// initializes the limit and the balance.
	constructor(address payable pb_owner, uint pb_limit) public {
		owner = pb_owner;
		limit = pb_limit;
		balance = 0;
	}

	// modifier that allows public function to accept all calls before parameters decoding. 
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// modifier that allows public function to be called only from the owners address.
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	// modifier that allows public function to be called only when the limit is reached.
	modifier checkBalance() {
		require(balance >= limit);
		_;
	}

	// function that can be called by anyone.
	function deposit() public payable alwaysAccept {
		balance += msg.value;
	}

	// function that can be called only by the owner after reaching the limit.
	function withdraw() public alwaysAccept onlyOwner checkBalance {
		msg.sender.transfer(balance);
		balance = 0;
	}

}
