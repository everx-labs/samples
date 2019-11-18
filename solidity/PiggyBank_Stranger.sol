pragma solidity ^0.5.0;

// This contract describes the Stranger who can add to deposit of PiggyBank but can't withdraw deposit.

// PiggyBank interface
contract PiggyBank {
	function deposit() public payable;
	function withdraw() public;
}

contract Stranger {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	uint depositCounter = 1000;

	// function to deposit money to piggy bank.
	function addToDeposit(PiggyBank bankAddress, uint amount) public alwaysAccept {
		bankAddress.deposit.value(amount)();
		depositCounter++;
	}

	// function to withdraw money from piggy bank.
	function withdrawDeposit(PiggyBank bankAddress) public alwaysAccept {
		bankAddress.withdraw();
	}
}
