pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

import "6_DBClientInterface.sol";

// This contract implements IDataBaseClient interface.
contract DataBaseClient is IDataBaseClient {
	// State variable storing the number of receive* functions were called.
	uint public receiptCounter = 0;

	// State variable that can be used to check received values.
	uint public checkSum = 0;

	constructor () {
		tvm.accept();
	}

	// Function receives an array of uint64 values.
	function receiveArray(uint64[] arr) external override {
		uint sum = 0;
		uint len = arr.length;
		for (uint i = 0; i < len; i++) {
			sum += arr[i];
		}
		checkSum = sum;
		receiptCounter++;
	}

	// Function receives five arrays of uint values.
	function receiveFiveArrays(uint256[] a0, uint256[] a1, uint256[] a2, uint256[] a3, uint256[] a4) external override {
		checkSum = a0[0];
		checkSum = (checkSum << 4) + a1[0];
		checkSum = (checkSum << 4) + a2[0];
		checkSum = (checkSum << 4) + a3[0];
		checkSum = (checkSum << 4) + a4[0];
		receiptCounter++;
	}

	// Function receives five uint256 values.
	function receiveFiveUint256(uint256 a0, uint256 a1, uint256 a2, uint256 a3, uint256 a4) external override {
		checkSum = a0;
		checkSum = (checkSum << 4) + a1;
		checkSum = (checkSum << 4) + a2;
		checkSum = (checkSum << 4) + a3;
		checkSum = (checkSum << 4) + a4;
		receiptCounter++;
	}

	// Function receives an array of structures.
	function receiveStructArray(MyStruct[] arr) external override {
		checkSum = arr[0].ID * 1_000 + arr[0].value * 100 +
		           arr[1].ID * 10    + arr[1].value;
		receiptCounter++;
	}
}
