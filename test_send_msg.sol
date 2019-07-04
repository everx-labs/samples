pragma solidity ^0.5.0;

contract MyContract {

/*
	function get_allowance(address requester) public returns(uint) {
		MyContract r = MyContract(requester);
		r.on_get_allowance(0);
		return 0;
	}
*/	

	function get_allowance(MyContract requester) pure public returns(uint) {
		// call remote contract
		requester.on_get_allowance(0);
		return 0;
	}
	
	// Dummy function for a remote contract. Later to be represented by a distinct interface
	
	function on_get_allowance(uint64 amount) pure public {
		require(amount > 0);
		return; 
	}
	
}
