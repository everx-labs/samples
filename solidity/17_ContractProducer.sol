pragma solidity >= 0.6.0;

import "17_SimpleWallet.sol";

// Contract deployed wallet contracts.
contract WalletProducer {

	// Number of deployed contracts.
	uint m_deployedNumber = 0;
	// Wallet's code.
	TvmCell m_walletCode;

	constructor(TvmCell walletCode) public {
		// Check that contract's public key is set.
		require(tvm.pubkey() != 0, 101);
		// Check that constructor is called by owner (message is signed by correct public key).
		require(tvm.pubkey() == msg.pubkey(), 102);

		tvm.accept();

		m_walletCode = walletCode;
	}

	modifier checkOwnerAndAccept {
		require(tvm.pubkey() == msg.pubkey());
		tvm.accept();
		_;
	}

	// Function deploys a wallet contract with specified public key
	function deployWallet(uint256 publicKey0, uint256 publicKey1)
		public
		checkOwnerAndAccept
		returns (address newWallet)
	{
		uint id = m_deployedNumber;
		uint n = 10;
		newWallet = new SimpleWallet{
			// code of the new contract
			code: m_walletCode,
			// value sent to the new contract
			value: 1 ton,
			// contract's public key (in the new contract it can be obtained with 'tvm.pubkey()')
			pubkey: publicKey0,
			// New contract public variables initialization
			varInit: {
				m_id: id,
				m_creator: address(this)
			}
		}(n, publicKey1); // 'n' and 'publicKey1' are parameter of the constructor.

		++m_deployedNumber;
	}

	/*
     * Public Getters
     */
	function getData() public view returns (uint qty, uint hash) {
		return (m_deployedNumber, tvm.hash(m_walletCode));
	}

}
