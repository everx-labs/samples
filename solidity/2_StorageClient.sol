pragma solidity >=0.6.0;
pragma AbiHeader expire;

// import interface 'Storage'
import "2_UintStorage.sol";

// This contract calls the remote contract function with parameter to store a uint value in the remote contract's
// persistent memory.
contract StorageClient {

	// State variable storing the number of times 'store' function was called.
	uint callCounter = 0;

	constructor () public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(tvm.pubkey() == msg.pubkey(), 101);
		tvm.accept();
		_;
	}

	function store(Storage storageAddress, uint value) public checkOwnerAndAccept {
		// Call the remote contract function with parameter.
		storageAddress.storeValue(value);
		// Increment the counter.
		callCounter++;
	}

}
