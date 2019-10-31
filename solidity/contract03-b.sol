pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint value) public;
}


contract MyContract is AnotherContract {

	// runtime function that allows contract to process external messages, which bring 
	// no value with themselves.
	function tvm_accept() private pure {}

	// modifier that allows public function to accept all calls before parameters decoding. 
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	// state variable storing the number of times 'remoteMethod' function was called
	uint m_callCounter;

	// A function to be called from another contract
	// This function receives parameter 'value' from another contract and
	// transfers value to the caller.
	function remoteMethod(uint value) public alwaysAccept {
		msg.sender.transfer(value);
		m_callCounter++;
		return; 
	}
	
}
