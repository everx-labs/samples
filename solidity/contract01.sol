pragma solidity ^0.5.0;

contract Test01 {

	// runtime function that allows contract to process external messages, which bring 
	// no value with themselves.
	function tvm_accept() private pure {}

	// modifier that allows public function to accept all calls before parameters decoding. 
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	// state variable storing the sum of parameters that were
	// passed to function 'main'
	uint32 m_accumulator;

	function main(uint32 a) public alwaysAccept {
		uint32 res = m_accumulator + a;
		m_accumulator = res;
	}

}
