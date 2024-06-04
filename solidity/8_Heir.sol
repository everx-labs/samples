pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

// The contract receives all the balance of Kamikaze contract after its self-destruction.
contract Heir {

	// State variable storing the number of times receive was called.
	uint public heritageCounter;

	constructor () {
		tvm.accept();
	}

	// Receive function that will be called after Kamikaze contract self-destruction.
    receive() external {
		heritageCounter++;
	}
}
