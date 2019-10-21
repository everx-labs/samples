pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint64 value) public;
}

// this contract implements 'AnotherContract' interface
contract MyContract is AnotherContract {

	uint64 m_value;
	address m_address;

	// A function to be called from another contract.
	// This function receives parameter 'value' from another contract and
	// saves this value in the state variable 'm_value' of this contract.
	// Also this function saves the address of the contract that called 'remoteMethod'
	// in the state variable 'm_address'.
	function remoteMethod(uint64 value) public {
		m_value = value;
		m_address = msg.sender;
		return;
	}

}
