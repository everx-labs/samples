pragma solidity ^0.5.0;

contract Test01 {

	// state variable storing the sum of parameters that were
	// passed to function 'main'
	uint32 m_accumulator;

	function main(uint32 a) public {
		uint32 res = m_accumulator + a;
		m_accumulator = res;
	}

}
