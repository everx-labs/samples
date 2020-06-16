pragma solidity >=0.5.0;

// The contract receives all the balance of Kamikaze contract after its self-destruction.
contract Heir {

	// State variable storing the number of times fallback function was called.
	uint heritageCounter;

	fallback() external {
		heritageCounter++;
	}
	// Receive function that will be called after Kamikaze contract self-destruction.
    receive() external {
		heritageCounter++;
	}

	function getCounter() public returns(uint) {
		tvm.accept();
		return heritageCounter;
	}
}
