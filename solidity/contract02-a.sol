pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint64 value) pure public;
}

// the contract calling the remote method with parameter
contract MyContract {

	// persistent variable storing the number of function 'method' was called
	uint m_counter;

	function method(AnotherContract anotherContract) public {
		// call function of remote contract with parameter
		anotherContract.remoteMethod(257);
		// incrementing the counter
		m_counter = m_counter + 1;
		return;
	}

}
