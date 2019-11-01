pragma solidity ^0.5.0;

// This sample demonstrates usage of selfdestruct function.

contract Kamikaze {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	uint m_counter;

	function sendAllMoney(address payable dest_addr) public alwaysAccept {
		selfdestruct(dest_addr);
	}

	function() public payable {
		m_counter++;
	}
}
