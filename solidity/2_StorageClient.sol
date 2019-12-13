pragma solidity ^0.5.0;

// Remote contract interface.
contract Storage {
	function storeValue(uint value) public;
}

// This contract calls the remote contract function with parameter to store a uint value in the remote contract's
// persistent memory.
contract StorageClient {

	// Runtime function that allows contract to process inbound messages spending 
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Modifier that allows public function to accept all external calls. 
	modifier alwaysAccept {
		tvm_accept(); 
		_;
	}

	// State variable storing the number of times 'store' function was called.
	uint callCounter = 0;

	function store(Storage storageAddress) public alwaysAccept {
		// Call the remote contract function with parameter.
		storageAddress.storeValue(257);
		// Increment the counter.
		callCounter++;
	}

}
