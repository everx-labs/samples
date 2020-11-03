pragma solidity >=0.6.0;
pragma AbiHeader expire;

// Remote contract interface.
interface Storage {
	function storeValue(uint value) external;
}

// This contract implements 'Storage' interface.
contract UintStorage is Storage {

	// State variables:
	uint value;                // storage for a uint value;
	address clientAddress;    // last caller address.

	// This function can be called only by another contract. There is no 'tvm.accept()'
	function storeValue(uint v) public override {
		// save parameter v to contract's state variable
		value = v;
		// save address of callee
		clientAddress = msg.sender;
	}

	/*
	 * Public Getters
	 */
	function getData() public returns(uint v, address client){
		v = value;
		client = clientAddress;
	}
}
