pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint value) public;
}


contract MyContract is AnotherContract {

	// state variable storing the number of 'remoteMethod' function calls
	uint m_callCounter;

	// A function to be called from another contract
	// This function receives parameter 'value' from another contract and
	// transfers value to the caller.
	function remoteMethod(uint value) public {
		msg.sender.transfer(value);
		m_callCounter++;
		return; 
	}
	
}
