pragma solidity ^0.5.0;

contract IRemoteContract {
	function remoteMethod(uint16 x) public;
}

contract IRemoteContractCallback {
	function remoteMethodCallback(uint16 x) public;
}

contract MyContract is IRemoteContractCallback {

	uint m_result;

	// This function get address of contract and some value x
	// and cast address to IRemoteContract interface and call
	// method remoteMethod with parametr x
	function method(address anotherContract, uint16 x) public {
		IRemoteContract(anotherContract).remoteMethod(x);
		return;
	}
	
	// interface IRemoteContractCallback
	// A method to be called from RemoteContract
	function remoteMethodCallback(uint16 x) public {
		// save paramets x in persistent variable 'm_result'
		m_result = x;
		return;
	}
}
