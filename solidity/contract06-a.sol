pragma solidity ^0.5.0;

import "contract06.sol";

contract MyContract is IMyContract {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}
	
	uint m_callCounter;

	function method(IMyRemoteContract anotherContract) public alwaysAccept {
		// call remote contract
		anotherContract.remoteMethod();
		m_callCounter++;
		return;
	}
	
}
