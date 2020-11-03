pragma solidity >=0.6.0;
pragma AbiHeader expire;

import "9_PiggyBank.sol";

// This contract describes the Stranger who can add to deposit of PiggyBank but can't withdraw deposit.
contract Stranger {

	constructor () public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	modifier onlyOwner {
		// Check that message was signed with contracts key.
		require(tvm.pubkey() == msg.pubkey(), 101);
		_;
	}

	// Function to deposit money to piggy bank.
	function addToDeposit(PiggyBank bankAddress, uint amount) public onlyOwner {
		tvm.accept();
		bankAddress.deposit{value: amount}();
	}

	// Function to withdraw money from piggy bank.
	function withdrawDeposit(PiggyBank bankAddress) public view onlyOwner {
		tvm.accept();
		bankAddress.withdraw();
	}
}
