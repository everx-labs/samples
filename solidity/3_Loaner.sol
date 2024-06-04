pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

interface Loaner {
	function borrow(coins amount) external;
}

// This contract implements 'Loaner' interface.
contract LoanerContract is Loaner {

	constructor () {
		tvm.accept();
	}

	// A function to be called from another contract
	// This function receives parameter 'amount' from another contract and
	// transfers 'amount' of currency to the caller.
	function borrow(coins amount) external override {
		// Before 'accept' here can be some checks (e.g: check that msg.sender is in while list)
		tvm.accept();

		msg.sender.transfer(amount);
	}

}
