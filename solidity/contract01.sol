pragma solidity ^0.5.0;

contract Test01 {

	uint32 m_accumulator;
	
	function main(uint32 a) public {
		uint32 res = m_accumulator + a;
		m_accumulator = res;
	}

}
