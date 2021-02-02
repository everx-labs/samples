pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface Loaner {
	function borrow(uint128 amount) external;
}

// This contract implements 'Loaner' interface.
contract LoanerContract is Loaner {

	// A function to be called from another contract
	// This function receives parameter 'amount' from another contract and
	// transfers 'amount' of currency to the caller.
	function borrow(uint128 amount) public override {
		// Before 'accept' here can be some checks (e.g: check that msg.sender is in while list)
		tvm.accept();

		msg.sender.transfer(amount);
	}

}
