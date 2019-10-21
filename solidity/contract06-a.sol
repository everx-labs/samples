pragma solidity ^0.5.0;

import "contract06.sol";

contract MyContract is IMyContract {

	uint m_callCounter;

	function method(IMyRemoteContract anotherContract) public {
		// call remote contract
		anotherContract.remoteMethod();
		m_callCounter++;
		return;
	}
	
}
