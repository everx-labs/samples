pragma solidity >= 0.6.0;

// Import file with wallet source code.
import "17_SimpleWallet.sol";

// Contract that can deploy a wallet contract with specified public key.
contract WalletProducer {

	// Number of deployed contracts
	uint deployedNumber = 0;
	// Wallet stateInit
	TvmCell walletCode;

	// Constructor function initializes wallet stateInit and initial balance.
	constructor(TvmCell code) public {
		tvm.accept();
		require(tvm.pubkey() != 0);
		walletCode = code;
	}

	modifier checkOwnerAndAccept {
		require(tvm.pubkey() == msg.pubkey());
		tvm.accept();
		_;
	}

	// Function that allows to deploy a wallet contract with specified public key.
	function deployWallet(uint256 publicKey) public checkOwnerAndAccept returns (address newWallet) {
		// Insert public key into contract stateInit data field.
		TvmCell walletData = tvm.buildEmptyData(publicKey);
		TvmCell stateInit = tvm.buildStateInit(walletCode, walletData);

		// To deploy a contract via "new" expression developer must use it with special call options.
		// "stateInit" option defines the stateInit of deployed contract. "value" option defines amount
		// of currency, that will be sent to the new address.
		newWallet = new SimpleWallet{stateInit:stateInit, value: 1 ton}(deployedNumber);
		++deployedNumber;
	}

	/*
     * Public Getters
     */
	function getData() public view returns (uint qty, uint hash) {
		return (deployedNumber, tvm.hash(walletCode));
	}

}
