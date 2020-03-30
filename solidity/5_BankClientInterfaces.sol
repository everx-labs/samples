pragma solidity >=0.5.0;

//Contract interface file

abstract contract IBank {
	function getCreditLimit() public virtual;
	function loan(uint amount) public virtual;
}

abstract contract IBankClient {
	function setCreditLimit(uint limi) public virtual;
	function refusalCallback(uint remainingLimit) public virtual;
	function receiveLoan(uint totalDebt) public payable virtual;
}
