pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint value) public;
}

// the contract calling the remote contract function with parameter
contract MyContract {

	// state variable storing the number of 'method' function calls
	uint m_callCounter;

	function method(AnotherContract anotherContract, uint amount) public {
		// call function of remote contract with a parameter
		anotherContract.remoteMethod(amount);
		// incrementing the counter
		m_callCounter++;
		return;
	}

}
