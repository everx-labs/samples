pragma solidity ^0.5.0;

//Contract interface file

contract IBank {
	function getCreditLimit() public;
	function loan(uint amount) public;
}

contract IBankClient {
	function setCreditLimit(uint limi) public;
	function refusalCallback(uint remainingLimit) public;
	function receiveLoan(uint totalDebt) public payable;
}
