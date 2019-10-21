pragma solidity ^0.5.0;

// Import the interface file
import "contract05.sol";

contract RemoteContract is IMyContractCallback {

	uint64 m_credit;
	
	// external functions
	
	function getMyCredit(IMyContract bank) public {
		// call remote contract method 
		bank.getCredit();
		return;
	}
	
	// interface IMyContractCallback
	
	function getCreditCallback(uint64 balance) public {
		// save the credit balance (received from another contract) in a state variable
		m_credit = balance;
	}
	
}
