pragma ever-solidity >= 0.72.0;
pragma AbiHeader expire;

//Contract interface file

interface IBank {
	function getCreditLimit() external;
	function loan(uint amount) external;
}

interface IBankClient {
	function setCreditLimit(uint limit) external;
	function refusalCallback(uint remainingLimit) external;
	function receiveLoan(uint totalDebt) external;
}
