pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

// This contract is used to emulate currency transfer destination contract,
// it can accept incoming transfer via receive function or emulate crash in function doCrash().
contract CrashContract {
	
	uint public counter = 0;

	constructor () {
		tvm.accept();
	}

	receive() external {
		++counter;
	}

	// Function that just throws an exception
	function doCrash() external pure {
		revert(101);
	}
}
