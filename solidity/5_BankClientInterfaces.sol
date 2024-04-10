pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

//Contract interface file

interface IBank {
	function getCreditLimit() external;
	function loan(coins amount) external;
}

interface IBankClient {
	function setCreditLimit(uint limit) external;
	function refusalCallback(uint remainingLimit) external;
	function receiveLoan(uint totalDebt) external;
}
