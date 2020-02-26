pragma solidity >=0.5.0;

contract Accumulator {

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

	// State variable storing the sum of arguments that were passed to function 'add',
	// initialized with value 0.
	uint sum = 0;

	// Function that adds its argument to the state variable.
	function add(uint value) public alwaysAccept {
		sum += value;
	}

}
