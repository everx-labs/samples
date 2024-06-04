pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

import "11_SimpleContract.sol";
import "11_Waller_no_constructor.sol";

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

	// The second option of contract deployment
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

	// The third option of contract deployment
	function deployNoConstructor(TvmCell code) external checkOwnerAndAccept {
		TvmCell data = abi.encodeData({
			contr: Wallet,
			varInit: {
				m_creator: address(this)
			},
			pubkey: 0x3f82435f2bd40915c28f56d3c2f07af4108931ae8bf1ca9403dcf77d96250827
		});
		TvmCell stateInit = abi.encodeStateInit(code, data);
		// Get address of new contracts
		address addr = address.makeAddrStd(0, tvm.hash(stateInit));
		// Deploy the contract (that has no constructor) by calling `sendCoins` function
		Wallet(addr).sendCoins{stateInit: stateInit, value: 2 ever}(address(0x12345), 1 ever, false);

		// save address
		contracts.push(addr);
	}

	function deployNoConstructor2(TvmCell code) public checkOwnerAndAccept {
		TvmCell data = abi.encodeData({
			contr: Wallet,
			varInit: {
				m_creator: address(this)
			},
			pubkey: 0x3f82435f2bd40915c28f56d3c2f07af4108931ae8bf1ca9403dcf77d96250828
		});
		TvmCell stateInit = abi.encodeStateInit(code, data);
		// Deploy the contract (that has no constructor) by calling `receive` function
		address addr = address.makeAddrStd(0, tvm.hash(stateInit));
		addr.transfer({stateInit: stateInit, value: 1 ever});

		// save address
		contracts.push(addr);
	}
}
