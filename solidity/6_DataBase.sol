pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "6_DBClientInterface.sol";

// This contract demonstrates how to send different amounts of information to another contract.
contract DataBase {

	uint64 constant ATTACHED_VALUE = 1 ton;

	// Modifier that allows public function to accept all external messages.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

	// Contract can store or generate different coefficients and provide them
	// upon request as an array of integers.
	// Function sends an array of uint64  with size 'count' to the contract
	// with address 'receiver'.
	function sendArray(address receiver, uint64 count) public pure alwaysAccept {
		uint64[] arr = new uint64[](count);
		for (uint64 i = 0; i < count; i++) {
			arr[i] = i + 1;
		}
		IDataBaseClient(receiver).receiveArray{value: ATTACHED_VALUE}(arr);
	}

	// Function sends five arrays of uint to the contract with address 'receiver'.
	function sendFiveArrays(address receiver) public pure alwaysAccept {
		uint[] arr0 = [uint(1)];
		uint[] arr1 = [uint(2)];
		uint[] arr2 = [uint(3)];
		uint[] arr3 = [uint(4)];
		uint[] arr4 = [uint(5)];
		IDataBaseClient(receiver).receiveFiveArrays{value: ATTACHED_VALUE}(arr0, arr1, arr2, arr3, arr4);
	}

	// Function sends five uint256 to the contract with address 'receiver'.
	function sendFiveUint256(address receiver) public pure alwaysAccept {
		uint256 a0 = 5;
		uint256 a1 = 4;
		uint256 a2 = 3;
		uint256 a3 = 2;
		uint256 a4 = 1;
		IDataBaseClient(receiver).receiveFiveUint256{value: ATTACHED_VALUE}(a0, a1, a2, a3, a4);
	}

	// Private function to create an array of structures, that will be sent to another contract.
	function createStructArray() private pure returns (MyStruct[]) {
		MyStruct[] arr = [
			MyStruct({
				ID: 1,
				value: 2
			}),
			MyStruct({
				ID: 3,
				value: 4
			})
		];
		return arr;
	}

	// Function sends an array of structures to the contract with address 'receiver'.
	function sendStructArray(address receiver) public pure alwaysAccept {
		MyStruct[] arr = createStructArray();
		IDataBaseClient(receiver).receiveStructArray{value: ATTACHED_VALUE}(arr);
	}
}
