pragma solidity ^0.5.0;

// Import the interface file
import "contract05.sol";

contract RemoteContract is IMyContractCallback {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}
	
	uint64 m_credit;
	
	// external functions
	
	function getMyCredit(IMyContract bank) public alwaysAccept {
		// call remote contract method 
		bank.getCredit();
		return;
	}
	
	// interface IMyContractCallback
	
	function getCreditCallback(uint64 balance) public alwaysAccept {
		// save the credit balance (received from another contract) in a state variable
		m_credit = balance;
	}
	
}
