pragma solidity ^0.5.0;

// Import the interface file
import "5_BankClientInterfaces.sol";

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

	// State variables:
	uint creditLimit = 0;    // allowed credit limit;
	uint totalDebt = 0;      // contract total debt;
	uint balance = 0;        // contract balance;
	uint value = 0;          // inbound message value.


	// This function calls a remote IBankDataBase contract to get the credit limit.
	function getMyCredit(IBank bank) public alwaysAccept {
		// Call remote contract function.
		bank.getCreditLimit();
	}

	// A callback function to set the credit limit.
	function setCreditLimit(uint limit) public alwaysAccept {
		// Save the credit limit (received from another contract) in the state variable.
		creditLimit = limit;
	}

	//This function calls bank contract to ask for a loan.
	function askForALoan(IBank bank, uint amount) public alwaysAccept {
		balance = address(this).balance;
		bank.loan(amount);
	}

	// A callback payable function to receive requested loan. Function receives the total debt as an argument.
	function receiveLoan(uint n_totalDebt) public payable alwaysAccept {
		value = msg.value;
		uint n_balance = address(this).balance;
		require(n_balance > balance);
		balance = n_balance;
		totalDebt = n_totalDebt;
	}

	// A callback function to indicate refuse of the loan request. Function receives available limit as an argument.
	function refusalCallback(uint availableLimit) public alwaysAccept {
		creditLimit = availableLimit;
	}
}
