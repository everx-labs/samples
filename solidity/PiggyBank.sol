pragma solidity ^0.5.0;

contract PiggyBank {

	// state variables: 
	address payable m_owner;	// contract owner's address
	uint m_limit;			// piggybank's minimal limit to withdraw
	uint m_balance;			// piggybank's deposit balance
	
	// runtime function that allows contract to process external messages, which bring 
	// no value with themselves.
	function tvm_accept() private pure {}

	// constructor saves the address of the contract owner in a state variable and
	// initializes the limit and the balance.
	constructor(address payable owner, uint limit) public {
		m_owner = owner;
		m_limit = limit;
		m_balance = 0;
	}

	// modifier that allows public function to accept all calls before parameters decoding. 
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// modifier that allows public function to be called only from the owners address.
	modifier onlyOwner {
		require(msg.sender == m_owner);
		_;
	}

	// modifier that allows public function to be called only when the limit is reached.
	modifier checkBalance() {
		require(m_balance >= m_limit);
		_;
	}

	// function that can be called by anyone.
	function deposit() public payable alwaysAccept {
		m_balance += msg.value;
	}

	// function that can be called only by the owner after reaching the limit.
	function withdraw() public alwaysAccept onlyOwner checkBalance {
		msg.sender.transfer(m_balance);
		m_balance = 0;
	}

}
