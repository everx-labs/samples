pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This sample demonstrates usage of selfdestruct function.
contract Kamikaze {

	// Constructor saves the owner's public key in the state variable.
	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Due to the modifier checkOwnerAndAccept function sendAllMoney can be
	// called only by the owner of the contract.
	function sendAllMoney(address dest) public checkOwnerAndAccept {
		selfdestruct(dest);
	}
}
