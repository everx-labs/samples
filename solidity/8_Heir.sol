pragma solidity >=0.6.0;
pragma AbiHeader expire;

// The contract receives all the balance of Kamikaze contract after its self-destruction.
contract Heir {

	// State variable storing the number of times fallback function was called.
	uint heritageCounter;

	// Receive function that will be called after Kamikaze contract self-destruction.
    receive() external {
		heritageCounter++;
	}

	/*
 	 * Public Getters
 	 */
	function getCounter() public view returns(uint qty) {
		return heritageCounter;
	}
}
