pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

// Remote contract interface.
interface Storage {
	function storeValue(uint value) external;
}

// This contract implements 'Storage' interface.
contract UintStorage is Storage {

	// State variables:
	uint public value;                // storage for a uint value;
	address public clientAddress;    // last caller address.

	constructor () {
		tvm.accept();
	}

	// This function can be called only by another contract. There is no 'tvm.accept()'
	function storeValue(uint v) external override {
		// save parameter v to contract's state variable
		value = v;
		// save address of callee
		clientAddress = msg.sender;
	}
}
