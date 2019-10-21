pragma solidity ^0.5.0;

// This sample demonstrates usage of selfdestruct function.

contract Kamikaze {
	uint m_counter;

	function sendAllMoney(address payable dest_addr) public {
		selfdestruct(dest_addr);
	}

	function() public payable {
		m_counter++;
	}
}
