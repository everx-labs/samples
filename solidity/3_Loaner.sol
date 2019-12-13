pragma solidity ^0.5.0;

// Remote contract interface
contract Loaner {
	function borrow(uint amount) public;
}

// This contract implements 'Loaner' interface.
contract LoanerContract is Loaner {

	// Runtime function that allows contract to process inbound messages spending 
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Modifier that allows public function to accept all external calls. 
	modifier alwaysAccept {
		tvm_accept(); 
		_;
	}

	// State variable storing the number of times 'borrow' function was called.
	uint callCounter = 0;

	// A function to be called from another contract
	// This function receives parameter 'amount' from another contract and
	// transfers 'amount' of currency to the caller.
	function borrow(uint amount) public alwaysAccept {
		msg.sender.transfer(amount);
		callCounter++;
		return; 
	}
	
}
