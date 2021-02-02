pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// Import the interface file
import "5_BankClientInterfaces.sol";

// This contract implements 'IBank' interface.
// The contract allows to store credit limits in mapping and give to the caller it's credit limits.
contract Bank is IBank {

	// Struct for storing the credit information.
	struct CreditInfo {
		uint allowed;
		uint used;
	}

	// State variable storing a credit information for addresses.
	mapping(address => CreditInfo) clientDB;


	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Set credit limit for the address.
	function setAllowance(address bankClientAddress, uint amount) public checkOwnerAndAccept {
        // Store allowed credit limit for the address in state variable mapping.
		clientDB[bankClientAddress].allowed = amount;
	}

	// Get allowed credit limit for the caller.
	function getCreditLimit() public override {
		// Cast caller to IMyContractCallback and invoke callback function
		// with value obtained from state variable mapping.
        CreditInfo borrowerInfo = clientDB[msg.sender];
		IBankClient(msg.sender).setCreditLimit(borrowerInfo.allowed - borrowerInfo.used);
	}

	// This function checks whether message sender's available limit could be loaned
	// and sends currency.
	function loan(uint amount) public override {
		CreditInfo borrowerInfo = clientDB[msg.sender];
		if (borrowerInfo.used + amount > borrowerInfo.allowed) {
		    IBankClient(msg.sender).refusalCallback(borrowerInfo.allowed - borrowerInfo.used);
		} else {
		    // '{value: amount}' allows to attach arbitrary amount of currency to the message
		    // if it is not set amount would be set to 10 000 000 nanoton
		    IBankClient(msg.sender).receiveLoan{value: uint128(amount)}(borrowerInfo.used + amount);
		    clientDB[msg.sender].used += amount;
		}
	}

}
