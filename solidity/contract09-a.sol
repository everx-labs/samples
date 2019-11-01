pragma solidity ^0.5.0;

contract CrashContact {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	uint m_counter;

	// Fallback function
	function() public payable {
		m_counter += 1001;
	}

	function doCrash(uint value) public pure alwaysAccept {
		require(value == 0, 73);
	}
}
