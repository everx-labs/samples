pragma solidity >=0.5.0;

// The contract receives all the balance of Kamikaze contract after its self-destuction.
contract Heir {

	// State variable storing the number of times fallback function was called.
	uint heritageCounter;

	// Fallback function that will be called after Kamikaze contract self-destruction.
	fallback() external payable {
		heritageCounter++;
	}
}
