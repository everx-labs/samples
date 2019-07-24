pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod() pure public;
}

// the contract calling the remote method without parameters
contract MyContract {

	// persistent variable storing the number of function 'method' was called
	uint m_counter;

	function method(AnotherContract anotherContract) public {
		// call function of remote contract without parameters
		anotherContract.remoteMethod();
		// incrementing the counter
		m_counter = m_counter + 1;
		return;
	}
	
}
