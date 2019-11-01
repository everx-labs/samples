pragma solidity ^0.5.0;

import "contract09-a.sol";

contract IRemoteContract {
	function someMethod(uint64 number) payable public;
}

// This sample demonstrates usage of the fallback functions. Such function is executed
// on a call to the contract if none of the other functions match the given function
// identifier (or if no data was supplied at all).

contract Caller {
	function tvm_transfer(address payable remote_addr, uint128 grams_value, bool bounce, uint16 sendrawmsg_flag) pure private {}
	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	uint m_counter;

	// Fallback function
	function() public payable {
		tvm_accept();
		m_counter += 1001;
	}

	function sendMoney(address payable dest_addr, uint cmd) public alwaysAccept {
		if (cmd == 0) {
			// send some grams to the dest_addr
			dest_addr.transfer(3000000);
		} else if (cmd == 1) {
			// make the callee contract crash
			CrashContact(dest_addr).doCrash(12345);
		} else if (cmd == 2) {
			// call an invalid method
			IRemoteContract(dest_addr).someMethod(123);
		} else {
			require(false);
		}
	}

	// Function which can make a transfer with arbitrary settings (unlike addr.transfer()
	// that has some of parameters constantly set) and can be used to send grams to 
	// non-existing address.
	function do_tvm_transfer(address payable remote_addr, uint128 grams_value, bool bounce, uint16 sendrawmsg_flag) pure public alwaysAccept {
		tvm_transfer(remote_addr, grams_value, bounce, sendrawmsg_flag);
	}

}
