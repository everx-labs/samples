pragma solidity ^0.5.0;

// the interface of a remote contract
contract AnotherContract {
	function remoteMethod(uint value) pure public;
}


contract MyContract is AnotherContract {

	// persistent variable storing the number of function 'remoteMethod' was called
	uint m_counter;

	function tvm_logstr(bytes32 logstr) private {}

	// A method to be called from another contract
	// This method receive parameter 'value' from another contract and
	// and transfer to caller value
	function remoteMethod(uint value) public {
		tvm_logstr("SendMoney");
		msg.sender.transfer(value);
		m_counter = m_counter + 1;
		return; 
	}
	
}
