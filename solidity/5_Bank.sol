pragma solidity ^0.5.0;

// Import the interface file
import "5_BankClientInterfaces.sol";

// This contract implements 'IBank' interface.
// The contract allows to store credit limits in mapping and give to the caller it's credit limits.
contract Bank is IBank {

	// Runtime function that allows contract to process inbound messages spending
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// Struct for storing the credit information.
	struct CreditInfo {
		uint allowed;
		uint used;
	}

	// State variable storing a credit infomation for addresses.
	mapping(address => CreditInfo) clientDB;

	// Set credit limit for the address.
	function setAllowance(address bankClientAddress, uint amount) public alwaysAccept {
        // Store allowed credit limit for the address in state variable mapping.
		clientDB[bankClientAddress].allowed = amount;
	}

	// Get allowed credit limit for the caller.
	function getCreditLimit() public alwaysAccept {
		// Cast calleer to IMyContractCallback and call callback function
		// with value obtained from state variable mapping.
        	CreditInfo memory borrowerInfo = clientDB[msg.sender];
		IBankClient(msg.sender).setCreditLimit(borrowerInfo.allowed - borrowerInfo.used);
		return;
	}

	// This function checks whether message sender's available limit could be loaned
	// and sends currency.
	function loan(uint amount) public alwaysAccept {
		CreditInfo memory borrowerInfo = clientDB[msg.sender];
		if (borrowerInfo.used + amount > borrowerInfo.allowed)
		    IBankClient(msg.sender).refusalCallback(borrowerInfo.allowed - borrowerInfo.used);
		// '.value(amount)' allows to attach arbitrary amount of currency to the message
		// if it is not set amount would be set to 10 000 000
		IBankClient(msg.sender).receiveLoan.value(amount)(borrowerInfo.used + amount);
		clientDB[msg.sender].used += amount;
	}

}
