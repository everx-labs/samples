pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint64 value) public;
}

// the contract calling the remote contract method with parameter
contract MyContract {

	// state variable storing the number of 'method' function calls
	uint m_callCounter;

	function method(AnotherContract anotherContract) public {
		// call remote contract function with parameter
		anotherContract.remoteMethod(257);
		// increment the counter
		m_callCounter++;
		return;
	}

}
