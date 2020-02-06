pragma solidity ^0.5.0;

// Remote contract interface.
contract Loaner {
	function borrow(uint amount) public;
}

// This contract calls the remote contract function with parameter to ask remote contract to transfer
//  <amount> of currency.
contract Borrower {

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm.accept(); 	// Runtime function that allows contract to process inbound messages spending
				// it's own resources (it's necessary if contract should process all inbound messages,
				// not only those that carry value with them).
		_;
	}

	// State variable storing the number of times 'askForALoan' function was called.
	uint callCounter = 0;

	function askForALoan(Loaner loanerAddress, uint amount) public alwaysAccept {
		// Call the remote contract function with parameter.
		loanerAddress.borrow(amount);
		// Increment the counter.
		callCounter++;
	}

}
