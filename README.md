Contract MyContract (contract03-a) demonstrates how to call a remote contract. 
The remote contract (contract03-b) records a call and saves the address of the caller in a persistent variable.
```
// A method to be called from another contract
	// This method save address of calleer in persistent variable 'm_value' of this contract
	function remoteMethod() public {
		m_value = msg.sender;
		return; 
```
where **msg.sender** is the address of contract03-a saved by contract03-b.
