pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod() pure public;
}

// this contract implement 'AnotherContract' interface
contract MyContract is AnotherContract {

	address m_value;
	
	// A method to be called from another contract
	// This method save address of calleer in persistent variable 'm_value' of this contract
	function remoteMethod() public {
		m_value = msg.sender;
		return; 
	}
	
}
