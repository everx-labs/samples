pragma solidity ^0.5.0;

// Import the interface file
import "contract05.sol";

// This sample contract demonstrates signatures, mappings, structures and intercontract communtications

contract MyContract is IMyContract {

	// struct for storing the credit information.
	struct ContractInfo {
		uint64 allowed;
	}

	// state variable storing a credit infomation for addresses
	mapping(address => ContractInfo) m_allowed;
	
	// External messages
	
	// set the credit limit for the address
	function setAllowance(address anotherContract, uint64 amount) public {
		m_allowed[anotherContract].allowed = amount;
	}
	
	// Internal messages
	
	function getCredit() public {
		// cast calleer to IMyContractCallback and call method getCreditCallback
		// with value obtained from state variable
		IMyContractCallback(msg.sender).getCreditCallback(m_allowed[msg.sender].allowed);
		return;
	}
	
}
