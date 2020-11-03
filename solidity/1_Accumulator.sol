pragma solidity >=0.6.0;
pragma AbiHeader expire;

contract Accumulator {

	// State variable storing the sum of arguments that were passed to function 'add',
	uint sum = 0;

	constructor () public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	// Modifier that allows to accept some external messages
	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(tvm.pubkey() == msg.pubkey(), 101);
		tvm.accept();
		_;
	}

	// Function that adds its argument to the state variable.
	function add(uint value) public checkOwnerAndAccept {
		sum += value;
	}

	/*
	 * Public Getters
	 */
	function getSum() public returns (uint s) {
		return sum;
	}
}
