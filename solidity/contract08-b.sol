pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "contract08.sol";

// Tests for sending and receiving arrays, set of big numbers and structures.

contract Receiver is IReceiver {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	// State variables are used to check whether the recieved values are valid
	uint m_counter;
	uint m_sum1;

	// Function recieves an array of uint64 
	function on_uint64(uint64[] memory arr) public alwaysAccept {
		uint sum = 0;
		uint len = arr.length;
		for (uint i = 0; i < len; i++) {
			sum += arr[i];
		}
		m_counter = sum;
	}

	// Function recieves two arrays of uint64 
	function on_two_uint64(uint64[] memory arr0, uint64[] memory arr1) public alwaysAccept {
		m_counter = 0;
		for (uint i = 0; i < arr0.length; i++) {
			m_counter += arr0[i];
		}
		m_sum1 = 0;
		for (uint i = 0; i < arr1.length; i++) {
			m_sum1 += arr1[i];
		}
	}

	// Function recieves five arrays of uint
	function on_five_arrays(uint256[] memory a0, uint256[] memory a1, uint256[] memory a2, uint256[] memory a3, uint256[] memory a4) public alwaysAccept {
		m_counter = a0[0];
		m_counter = (m_counter << 4) + a1[0];
		m_counter = (m_counter << 4) + a2[0];
		m_counter = (m_counter << 4) + a3[0];
		m_counter = (m_counter << 4) + a4[0];
	}

	// Function recieves five uint256
	function on_five_uint256(uint256 a0, uint256 a1, uint256 a2, uint256 a3, uint256 a4) public alwaysAccept {
		m_counter = a0;
		m_counter = (m_counter << 4) + a1;
		m_counter = (m_counter << 4) + a2;
		m_counter = (m_counter << 4) + a3;
		m_counter = (m_counter << 4) + a4;
	}

	// Function recieves an array of structures
	function on_MyStruct(MyStruct[] memory arr) public alwaysAccept {
		m_counter = arr[0].a * 1_000 + arr[0].b * 100 +
		            arr[1].a * 10    + arr[1].b;
	}
}
