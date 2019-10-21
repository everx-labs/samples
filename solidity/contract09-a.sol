pragma solidity ^0.5.0;

contract CrashContact {
	uint m_counter;

	// Fallback function
	function() public payable {
		m_counter += 1001;
	}

	function doCrash(uint value) public pure {
		require(value == 0, 73);
	}
}