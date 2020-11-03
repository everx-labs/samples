pragma solidity >=0.6.0;
pragma AbiHeader expire;

interface Loaner {
	function borrow(uint128 amount) external;
}

// This contract implements 'Loaner' interface.
contract LoanerContract is Loaner {

	// State variable storing the number of times 'borrow' function was called.
	uint callCounter = 0;

	// A function to be called from another contract
	// This function receives parameter 'amount' from another contract and
	// transfers 'amount' of currency to the caller.
	function borrow(uint128 amount) public override {
		// Before 'accept' here can be some checks (e.g: check that msg.sender is in while list)
		tvm.accept();

		msg.sender.transfer(amount);
		callCounter++;
	}

}
