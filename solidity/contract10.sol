pragma solidity ^0.5.0;

// This sample demonstrates usage of contract constructor

contract Contract10 {

	uint m_accumulator;

	constructor(uint accumulator) public {
		m_accumulator = accumulator + 456;
	}

}
