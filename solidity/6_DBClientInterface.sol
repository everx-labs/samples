pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct MyStruct {
	uint ID;
	uint value;
}

// Interface for a database client.
interface IDataBaseClient {
	function receiveArray(uint64[] arr) external;
	function receiveFiveArrays(uint256[] a0, uint256[] a1, uint256[] a2, uint256[] a3, uint256[] a4) external;
	function receiveFiveUint256(uint256 a0, uint256 a1, uint256 a2, uint256 a3, uint256 a4) external;
	function receiveStructArray(MyStruct[] arr) external;
}
