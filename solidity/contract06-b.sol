pragma solidity ^0.5.0;

import "contract06.sol";

contract MyRemoteContract is IMyRemoteContract {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	uint256 m_value;
	uint256 m_balance;
	
	// A function to be called from another contract
	// Function gets the balance of the message and stores it and the balance
	// of the contact in state variables.
	function remoteMethod() public payable alwaysAccept {
		m_value = msg.value;
		m_balance = address(this).balance;
		return; 
	}
	
}
