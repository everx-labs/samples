pragma solidity >=0.6.0;
pragma AbiHeader expire;

// This contract is used to emulate currency transfer destination contract,
// it can accept incoming transfer via fallback function or emulate crash in function doCrash().
contract CrashContract {
	
	uint counter = 0;

	receive() external {
		++counter;
	}

	// Function that crashes after call.
	function doCrash() public pure {
		revert(101);
	}

	/*
	 * Public Getters
	 */
	// Function to obtain fallback counter
	function getCounter() public view returns (uint qty) {
		return counter;
	}
}
