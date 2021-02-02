pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "9_PiggyBank.sol";

// This contract describes the owner of PiggyBank who can add to deposit and withdraw deposit.
contract Owner {

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier onlyOwner {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		_;
	}


	// Function to deposit money to piggy bank.
	function addToDeposit(PiggyBank bankAddress, uint128 amount) public pure onlyOwner {
		tvm.accept();
		bankAddress.deposit{value: amount}();
	}

	// Function to withdraw money from piggy bank.
	function withdrawDeposit(PiggyBank bankAddress) public pure onlyOwner {
		tvm.accept();
		bankAddress.withdraw();
	}
}
