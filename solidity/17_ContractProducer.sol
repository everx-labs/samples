pragma solidity >= 0.6.0;

// Import file with wallet source code.
import "17_SimpleWallet.sol";

// Contract that can deploy a wallet contract with specified public key.
contract WalletProducer {

	// Structure to save information about deployed contract.
	struct DeployedContract {
		address addr;
		uint256 pubkey;
	}

	// State variables:
	uint deployedNumber = 0;				// Number of deployed contracts;
	DeployedContract[] deployedContracts;	// Array of deployed contract structures;
	TvmCell walletStateInit;				// Wallet stateInit;
	uint128 initialValue;					// Initial balance transferred to the deployed address.

	modifier checkOwnerAndAccept {
		require(tvm.pubkey() == msg.pubkey());
		tvm.accept();
		_;
	}

	// Constructor function initializes wallet stateInit and initial balance.
	constructor(TvmCell _walletStateInit, uint128 _initialValue) public {
		tvm.accept();
		walletStateInit = _walletStateInit;
		initialValue = _initialValue;
	}

	// Function to update the wallet code.
	function updateWalletCode(TvmCell newStateInit) public checkOwnerAndAccept {
		walletStateInit = newStateInit;
	}

	// Function to update the initial wallet balance.
	function updateInitialValue(uint128 newInitialValue) public checkOwnerAndAccept {
		initialValue = newInitialValue;
	}

	// Getter functions.
	function getHashOfWalletStateInit() public view checkOwnerAndAccept returns (uint) {
		return tvm.hash(walletStateInit);
	}

	function getNumberOfDeployedContracts() public view checkOwnerAndAccept  returns (uint) {
		return deployedNumber;
	}

	function getDeployedContractInfo(uint number) public view returns (DeployedContract) {
		require(tvm.pubkey() == msg.pubkey());
		// Check that argument has valid value.
		require(number < deployedNumber);
		tvm.accept();
		return deployedContracts[number];
	}


	// Function that allows to deploy a wallet contract with specified public key.
	function deployWalletWithPubkey(uint256 pubkey) public checkOwnerAndAccept returns (address deployedContract) {
		// Insert public key into contract stateInit data field.
		TvmCell stateInitWithKey = tvm.insertPubkey(walletStateInit, pubkey);

		// To deploy a contract via "new" expression developer must use it with special call options.
		// "stateInit" option defines the stateInit of deployed contract. "value" option defines amount
		// of currency, that will be sent to the new address.
		address newWallet = new SimpleWallet{stateInit:stateInitWithKey, value:initialValue}(0);

		// Save information about deployed contract.
		deployedContracts.push(DeployedContract(newWallet, pubkey));
		deployedNumber++;

		// Return address of the deployed contract.
		return newWallet;
	}

}
