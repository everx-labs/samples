pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

contract ContractWithBug {
	// Version of the contract
	uint public m_version = 1;
	uint public m_value;

	constructor() {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	function setValue(uint a, uint b) external checkPubkeyAndAccept {
		m_value = a + b; // there is bug. It will be fixed in next version of contract. See 12_NewVersion.sol
	}

	// Modifier that allows public function to be called only by message signed with owner's pubkey.
	modifier checkPubkeyAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Function that changes the code of the contract.
	function updateContractCode(TvmCell newcode) external view checkPubkeyAndAccept {
		// Runtime function that creates an output action that would change this
		// smart contract code to that given by cell newcode.
		tvm.setcode(newcode);
		// Runtime function that replaces current code (in register C3) of the contract with newcode.
		// It needs to call new `onCodeUpgrade` function
		tvm.setCurrentCode(newcode);
		// store all state variable to cell
		TvmCell stateVars = abi.encode(m_version, m_value);
		// Call function onCodeUpgrade of the 'new' code.
		onCodeUpgrade(stateVars);
	}

	// This function will never be called. But it must be defined.
	function onCodeUpgrade(TvmCell stateVars) private pure {
	}
}
