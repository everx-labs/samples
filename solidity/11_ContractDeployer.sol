pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "11_SimpleContract.sol";

contract ContractDeployer {

	// addresses of deployed contracts
	address[] public contracts;

	constructor() public {
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

	// First variant of contract deployment.
	function deployWithPubkey(
		TvmCell stateInit,
		uint256 pubkey,
		uint128 initialBalance,
		uint paramA,
		uint32 paramB
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function that inserts public key into contracts data field.
		TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, pubkey);

		// Deploy a contract and call it's constructor.
		address addr = new SimpleContract{stateInit: stateInitWithKey, value: initialBalance}(paramA, paramB);

		// save address
		contracts.push(addr);
	}


	// Second variant of contract deployment.
	function deployFromCodeAndData(
		TvmCell code,
		TvmCell data,
		uint128 initialBalance,
		uint paramA,
		uint32 paramB
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function to generate StateInit from code and data cells.
		TvmCell stateInit = tvm.buildStateInit(code, data);

		address addr = new SimpleContract{stateInit: stateInit, value: initialBalance}(paramA, paramB);

		// save address
		contracts.push(addr);
	}


	// Third variant of contract deployment.
	function deployWithMsgBody(
		TvmCell stateInit,
		int8 wid,
		uint128 initialBalance,
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
