pragma solidity >=0.5.0;

// Interface for a database client.
abstract contract IDataBaseClient {

	struct MyStruct {
		uint ID;
		uint value;
	}

	function receiveArray(uint64[] memory arr) public virtual;
	function receiveFiveArrays(uint256[] memory a0, uint256[] memory a1, uint256[] memory a2, uint256[] memory a3, uint256[] memory a4) public virtual;
	function receiveFiveUint256(uint256 a0, uint256 a1, uint256 a2, uint256 a3, uint256 a4) public virtual;
	function receiveStructArray(MyStruct[] memory arr) public virtual;
}
