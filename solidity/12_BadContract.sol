pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract ContractWithBug {
	// Version of the contract
	uint public version = 1;
	uint public value;

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	function setValue(uint a, uint b) public checkPubkeyAndAccept {
		value = a + b; // there is bug. It will be fixed in next version of contract. See 12_NewVersion.sol
	}

	// Modifier that allows public function to be called only by message signed with owner's pubkey.
	modifier checkPubkeyAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Function that changes the code of current contract.
	function setCode(TvmCell newcode) public pure checkPubkeyAndAccept {
		// Runtime function that creates an output action that would change this
		// smart contract code to that given by cell newcode.
		tvm.setcode(newcode);
		// Runtime function that replaces current code of the contract with newcode.
		tvm.setCurrentCode(newcode);
		// Call function onCodeUpgrade of the 'new' code.
		onCodeUpgrade();
	}

	// After code upgrade caused by calling setCode function we may need to do some actions.
	// We can add them into this function with constant id.
	function onCodeUpgrade() private pure {
	}
}
