pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint value) pure public;
}

// the contract calling the remote method wit parameters
contract MyContract {

	// persistent variable storing the number of function 'method' was called
	uint m_counter;

	function method(AnotherContract anotherContract, uint amount) public {
		// call function of remote contract without parameters
		anotherContract.remoteMethod(amount);
		// incrementing the counter
		m_counter = m_counter + 1;
		return;
	}

}
