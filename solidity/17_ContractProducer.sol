pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "17_SimpleWallet.sol";

// Contract deployed wallet contracts.
contract WalletProducer {

	// Number of deployed contracts.
	uint public m_deployedNumber = 0;

	constructor() public {
		// Check that contract's public key is set.
		require(tvm.pubkey() != 0, 101);
		// Check that constructor is called by owner (message is signed by correct public key).
		require(tvm.pubkey() == msg.pubkey(), 102);

		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		require(tvm.pubkey() == msg.pubkey());
		tvm.accept();
		_;
	}

	// Function deploys a wallet contract with specified public key
	function deployWalletUsingCode(TvmCell walletCode, uint256 publicKey0, uint256 publicKey1)
		public
		checkOwnerAndAccept
		returns (address newWallet)
	{
		uint id = m_deployedNumber;
		uint n = 10;
		newWallet = new SimpleWallet{
			// code of the new contract
			code: walletCode,
			// value sent to the new contract
			value: 1 ton,
			// contract's public key (in the new contract it can be obtained by calling 'tvm.pubkey()')
			pubkey: publicKey0,
			// New contract public variables initialization
			varInit: {
				m_id: id,
				m_creator: address(this)
			}
		}(n, publicKey1); // 'n' and 'publicKey1' are parameters of the constructor.

		++m_deployedNumber;
	}

	function deployWalletUsingStateInit(TvmCell stateInit, uint256 publicKey1)
		public
		checkOwnerAndAccept
		returns (address newWallet)
	{
		uint n = 10;
		newWallet = new SimpleWallet{
			// stateInit of the new contract
			stateInit: stateInit,
			// value sent to the new contract
			value: 1 ton
		}(n, publicKey1); // 'n' and 'publicKey1' are parameters of the constructor.

		++m_deployedNumber;
	}


}
