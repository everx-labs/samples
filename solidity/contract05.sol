pragma solidity ^0.5.0;

//Contract interface file

contract IMyContract {
	function getCredit() public;
}

contract IMyContractCallback {
	function getCreditCallback(uint64 balance) public;
}

