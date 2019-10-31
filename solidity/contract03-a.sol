pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint value) public;
}

// the contract calling the remote contract function with parameter
contract MyContract {

	// runtime function that allows contract to process external messages, which bring 
	// no value with themselves.
	function tvm_accept() private pure {}

	// modifier that allows public function to accept all calls before parameters decoding. 
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	// state variable storing the number of times 'method' function was called
	uint m_callCounter;

	function method(AnotherContract anotherContract, uint amount) public alwaysAccept {
		// call function of remote contract with a parameter
		anotherContract.remoteMethod(amount);
		// incrementing the counter
		m_callCounter++;
		return;
	}

}
