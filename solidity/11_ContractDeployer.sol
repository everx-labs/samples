pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

import "11_SimpleContract.sol";

contract ContractDeployer {

	// addresses of deployed contracts
	address[] public contracts;

	constructor() {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	// Modifier that allows public function to accept external calls only from the contract owner.
	modifier checkOwnerAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// The first option of contract deployment.
	function deployFromCodeAndData(
		TvmCell code,
		TvmCell data,
		coins initialBalance,
		uint paramA,
		uint32 paramB
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function to generate StateInit from code and data cells.
		TvmCell stateInit = abi.encodeStateInit(code, data);

		address addr = new SimpleContract{stateInit: stateInit, value: initialBalance}(paramA, paramB);

		// save address
		contracts.push(addr);
	}


	// The second option of contract deployment.
	function deployWithMsgBody(
		TvmCell stateInit,
		int8 wid,
		coins initialBalance,
		TvmCell payload
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function to deploy contract with prepared msg body for constructor call.
		address addr = address.makeAddrStd(wid, tvm.hash(stateInit));
		addr.transfer({stateInit: stateInit, body: payload, value: initialBalance});

		// save address
		contracts.push(addr);
	}
}
