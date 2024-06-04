pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

contract GoodContract {
	// Version of the contract
	uint public m_version; // this value is set in 'onCodeUpgrade' function
	uint public m_value;
	mapping(uint => uint) m_map; // we added this new contract's state variable

	constructor () {
		tvm.accept();
	}

	function setValue(uint a, uint b) external checkPubkeyAndAccept {
		m_value = a * b; // Bug has been fixed here =)
	}

	// Modifier that allows public function to be called only by message signed with owner's pubkey.
	modifier checkPubkeyAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Function that changes the code of current contract.
	function updateContractCode(TvmCell newcode) external checkPubkeyAndAccept {
		// Runtime function that creates an output action that would change this
		// smart contract code to that given by cell newcode.
		tvm.setcode(newcode);
		// Runtime function that replaces current code (in register C3) of the contract with newcode.
		// It needs to call new `onCodeUpgrade` function
		tvm.setCurrentCode(newcode);
		TvmCell stateVars = abi.encode(m_version, m_value, m_map);
		// Call function onCodeUpgrade of the 'new' code.
		onCodeUpgrade(stateVars);
	}

	// This function will be called from old contract.
	// This function must have same signature as in old contract.
	function onCodeUpgrade(TvmCell stateVars) private {
		// in new contract we added new state variable. So we must reset storage
		tvm.resetStorage();

		// initialize state variables
		(m_version, m_value) = abi.decode(stateVars, (uint, uint));
		++m_version;
		m_map[100] = 200;
	}
}
