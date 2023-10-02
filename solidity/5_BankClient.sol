pragma ever-solidity >= 0.72.0;
pragma AbiHeader expire;

// Import the interface file
import "5_BankClientInterfaces.sol";

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {

	uint public creditLimit = 0;    // allowed credit limit;
	uint public totalDebt = 0;      // contract total debt;
	uint public balance = 0;        // contract balance;
	uint public value = 0;          // inbound message value.

	constructor() {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// This function calls a remote IBank contract to get the credit limit.
	function getMyCreditLimit(IBank bank) external view checkOwnerAndAccept {
		// Call remote contract function.
		bank.getCreditLimit();
	}

	// A callback function to set the credit limit.
	function setCreditLimit(uint limit) external override {
		// Save the credit limit (received from another contract) in the state variable.
		creditLimit = limit;
	}

	//This function calls bank contract to ask for a loan.
	function askForALoan(IBank bank, uint amount) external checkOwnerAndAccept {
		balance = address(this).balance;
		bank.loan(amount);
	}

	// A callback function to receive requested loan. Function receives the total debt as an argument.
	function receiveLoan(uint n_totalDebt) external override {
		value = msg.value;
		uint n_balance = address(this).balance;
		require(n_balance > balance);
		balance = n_balance;
		totalDebt = n_totalDebt;
	}

	// A callback function to indicate refuse of the loan request. Function receives available limit as an argument.
	function refusalCallback(uint availableLimit) external override {
		creditLimit = availableLimit;
	}
}
