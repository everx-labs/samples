pragma solidity ^0.5.0;

contract IMyContract {
	function getCredit() public;
}

contract IMyContractCallback {
	function getCreditCallback(uint64 balance) public;
}

contract RemoteContract is IMyContractCallback {

	uint64 m_credit;
	
	// external methods
	
	function getMyCredit(IMyContract bank) public {
		bank.getCredit();
		return;
	}
	
	// interface IMyContractCallback
	
	function getCreditCallback(uint64 balance) public {
		m_credit = balance;
	}
	
}
