pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "6_DBClientInterface.sol";

// This contract demonstrates how to send different amounts of information to another contract.
contract DataBase {

	// Runtime function that allows contract to process inbound messages spending
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// State variable storing the number of send* functions were called.
	uint sendCounter = 0;

	// Contract can store or generate different coefficients and provide them
	// upon request as an array of integers.
	// Function sends an array of uint64  with size 'count' to the contract
	// with address 'receiver'.
	function sendArray(address receiver, uint64 count) public alwaysAccept {
		uint64[] memory arr = new uint64[](count);
		for (uint64 i = 0; i < count; i++) {
			arr[i] = i + 1;
		}
		IDataBaseClient(receiver).receiveArray(arr);
		sendCounter++;
	}

	// Function sends five arrays of uint to the contract with address 'receiver'.
	function sendFiveArrays(address receiver) public alwaysAccept {
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
		IDataBaseClient(receiver).receiveFiveArrays(arr0, arr1, arr2, arr3, arr4);
		sendCounter++;
	}

	// Function sends five uint256 to the contract with address 'receiver'.
	function sendFiveUint256(address receiver) public alwaysAccept {
		uint256 a0 = 5;
		uint256 a1 = 4;
		uint256 a2 = 3;
		uint256 a3 = 2;
		uint256 a4 = 1;
		IDataBaseClient(receiver).receiveFiveUint256(a0, a1, a2, a3, a4);
		sendCounter++;
	}

	// Private function to create an array of structures, that will be sent to another contract.
	function createStructArray() private pure returns (IDataBaseClient.MyStruct[] memory) {
		IDataBaseClient.MyStruct[] memory arr;
		arr[0].ID = 1;
		arr[0].value = 2;
		arr[1].ID = 3;
		arr[1].value = 4;
		return arr;
	}

	// Function sends an array of structures to the contract with address 'receiver'.
	function sendStructArray(address receiver) public alwaysAccept {
		IDataBaseClient.MyStruct[] memory arr = createStructArray();
		IDataBaseClient(receiver).receiveStructArray(arr);
		sendCounter++;
	}
}
