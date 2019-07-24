pragma solidity ^0.5.0;

contract IRemoteContract {
	function remoteMethod(uint16 x) public;
}

contract IRemoteContractCallback {
	function remoteMethodCallback(uint16 x) public;
}

contract RemoteContract is IRemoteContract {

	uint16 m_value;
	
	// A method to be called from another contract
	function remoteMethod(uint16 x) public {
		// save paramets x in persistent variable 'm_value'
		m_value = x;
		// cast address of caller to IRemoteContractCallback interface and
		// call its 'remoteMethodCallback' method
		IRemoteContractCallback(msg.sender).remoteMethodCallback(x * 16);
		return; 
	}
	
}
