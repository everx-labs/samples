pragma solidity >=0.5.0;

import "7_CrashContract.sol";

abstract contract AbstractContract {
	function receiveTransfer(uint64 number) public payable virtual;
}


//This contract allows to perform diffent kinds of currency transactions and control the result using the fallback function.
contract Giver {

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

	// State variable storing the number of times fallback function was called.
	uint fallbackCounter = 0;

	// Fallback function that is executed on a call to the contract if none of the other
	// functions match the given function identifier. This function is also executed if
	// the caller meant to call a function that is not available.
	fallback() external payable {
		fallbackCounter += 1;
	}

	// This function can transfer currency to an existing contract with payable fallback
	// function.
	function transferToAddress(address payable destination, uint amount) public alwaysAccept {
		destination.transfer(amount);
	}

	// This function calls an AbstractContract which would cause a fallback function
	// call in case of this contract inexistance.
	function transferToAbstractContract(address payable destination, uint amount) public alwaysAccept {
		AbstractContract(destination).receiveTransfer.value(amount)(123);
	}

	// This function call a CrashContract's function which would cause a fallback
	// function call  after it crashes.
	function transferToCrashContract(address payable destination, uint amount) public alwaysAccept {
		CrashContract(destination).doCrash.value(amount)();
	}

	// Function which allows to make a transfer to an arbitrary address.
	function do_tvm_transfer(address payable remote_addr, uint128 grams_value, bool bounce, uint16 sendrawmsg_flag) pure public alwaysAccept {
		// Runtime function that allows to make a transfer with arbitrary settings
		// and can be used to send grams to non-existing address.
		tvm.transfer(remote_addr, grams_value, bounce, sendrawmsg_flag);
	}

}
