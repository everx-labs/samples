pragma solidity >=0.5.0;

// This contract is used to emulate currency transfer destination contract, it can accept incoming transfer via fallback function or emulate crash in function doCrash().
contract CrashContract {

	// State variable storing the number of times fallback function was called.
	uint fallbackCounter = 0;

	// Fallback function.
	fallback() external payable {
		fallbackCounter += 1;
	}

	receive() external payable {
		fallbackCounter += 1;
	}

	// Function to obtain fallback counter
	function getCounter() public view returns (uint) {
		tvm.accept();
		return fallbackCounter;
	}

	// Function that crashes after call.
	function doCrash() public payable {
		require(false, 73);
	}
}
