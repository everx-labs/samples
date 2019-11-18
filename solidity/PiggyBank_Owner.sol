pragma solidity ^0.5.0;

// This contract describes the owner of PiggyBank who can add to deposit and withdraw deposit.

// PiggyBank interface
contract PiggyBank {
	function deposit() public payable;
	function withdraw() public;
}

contract Owner {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	uint m_depositCounter;
	uint m_balance;

	// function to deposit money to piggy bank.
	function addToDeposit(PiggyBank bankAddress, uint amount) public alwaysAccept {
		bankAddress.deposit.value(amount)();
		m_depositCounter++;
	}

	// function to withdraw money from piggy bank.
	function withdrawDeposit(PiggyBank bankAddress) public alwaysAccept {
		bankAddress.withdraw();
	}
}
