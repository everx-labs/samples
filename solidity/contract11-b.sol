pragma solidity ^0.5.0;

// The contract receives all the balance of Kamikaze contract after its self-destuction.
contract Receiver {
	uint m_counter;

	function() public payable {
		m_counter++;
	}
}
