pragma solidity ^0.5.0;

// A sample contract demonstrating /*signatures,*/ mappings, structures and intercontract communications

contract IMyContract {
	function getCredit() public;
}

contract IMyContractCallback {
	function getCreditCallback(uint64 balance) public;
}

contract MyContract is IMyContract {

	struct ContractInfo {
		uint64	allowed;
	}

	mapping(address => ContractInfo) m_allowed;
	
	// External messages
	
	function setAllowance(address anotherContract, uint64 amount) public {
		m_allowed[anotherContract].allowed = amount;
		return;
	}
	
	// Internal messages

	function getCredit() public {
		IMyContractCallback(msg.sender).getCreditCallback(m_allowed[msg.sender].allowed);
		return;
	}
	
}
