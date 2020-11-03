pragma solidity >=0.6.0;
pragma AbiHeader expire;

import "3_Loaner.sol";

// This contract calls the remote contract function with parameter to ask remote contract to transfer
//  <amount> of currency.
contract Borrower {

	// State variable storing the number of times 'askForALoan' function was called.
	uint callCounter = 0;

	constructor () public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(tvm.pubkey() == msg.pubkey(), 101);
		tvm.accept();
		_;
	}

	function askForALoan(Loaner loanerAddress, uint128 amount) public checkOwnerAndAccept {
		// Call the remote contract function with parameter.
		loanerAddress.borrow(amount);
		// Increment the counter.
		callCounter++;
	}
}
