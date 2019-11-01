pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "contract08.sol";

// Tests for sending and receiving arrays, set of big numbers and structures.

contract Sender {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}
	
	uint m_counter;

	// Function sends an array of uint64 with size 'count' to the contract 
	// with address 'reciever'
	function send_uint64(address receiver, uint64 count) public alwaysAccept {
		uint64[] memory arr = new uint64[](count);
		for (uint64 i = 0; i < count; i++) {
			arr[i] = i+1;
		}
		IReceiver(receiver).on_uint64(arr);
		m_counter++;
	}

	// Function sends two arrays of uint64 with size 'count' to the contract 
	// with address 'reciever'
	function send_uint64_two(address receiver, uint64 count) public alwaysAccept {
		uint64[] memory arr0 = new uint64[](count);
		for (uint64 i = 0; i < count; i++) {
			arr0[i] = i+1;
		}
		uint64[] memory arr1 = new uint64[](count);
		for (uint64 i = 0; i < count; i++) {
			arr1[i] = 100 + i+1;
		}
		IReceiver(receiver).on_two_uint64(arr0, arr1);
		m_counter++;
	}

	// Function sends five arrays of uint to the contract with address 'reciever'
	function send_arrays(address receiver) public alwaysAccept {
		uint256[] memory arr0 = new uint[](1);
		arr0[0] = 1;
		uint256[] memory arr1 = new uint[](1);
		arr1[0] = 2;
		uint256[] memory arr2 = new uint[](1);
		arr2[0] = 3;
		uint256[] memory arr3 = new uint[](1);
		arr3[0] = 4;
		uint256[] memory arr4 = new uint[](1);
		arr4[0] = 5;
		IReceiver(receiver).on_five_arrays(arr0, arr1, arr2, arr3, arr4);
		m_counter++;
	}

	// Function sends five uint256 to the contract with address 'reciever'
	function send_uint256(address receiver) public alwaysAccept {
		uint256 a0 = 5;
		uint256 a1 = 4;
		uint256 a2 = 3;
		uint256 a3 = 2;
		uint256 a4 = 1;
		IReceiver(receiver).on_five_uint256(a0, a1, a2, a3, a4);
		m_counter++;
	}

	// Function creates an array of structures, that will be sent to another contract
	function createStructArray() private pure returns (IReceiver.MyStruct[] memory) {
		IReceiver.MyStruct[] memory arr;
		arr[0].a = 1;
		arr[0].b = 2;
		arr[1].a = 3;
		arr[1].b = 4;
		return arr;
	}

	// Function sends an array of structures to the contract with address 'reciever'
	function send_MyStruct(address receiver) public alwaysAccept {
		IReceiver.MyStruct[] memory arr = createStructArray();
		IReceiver(receiver).on_MyStruct(arr);
		m_counter++;
	}
}
