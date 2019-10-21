pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

// Tests for sending and receiving arrays, set of big numbers and structures.

contract IReceiver {

	struct MyStruct {
		uint a;
		uint b;
	}

	function on_uint64(uint64[] memory arr) public;
	function on_two_uint64(uint64[] memory arr0, uint64[] memory arr1) public;
	function on_five_arrays(uint256[] memory a0, uint256[] memory a1, uint256[] memory a2, uint256[] memory a3, uint256[] memory a4) public;
	function on_five_uint256(uint256 a0, uint256 a1, uint256 a2, uint256 a3, uint256 a4) public;
	function on_MyStruct(MyStruct[] memory arr) public;
}
