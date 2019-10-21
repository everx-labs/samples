pragma solidity ^0.5.0;

contract IRemoteContract {
	function acceptMoneyAndNumber(uint64 number) payable public;
}

contract RemoteContract is IRemoteContract {

	uint64 m_number;
	uint m_msg_value;

	// A function to be called from another contract
	// Funciton gets amount of grams attached to the message and
	// stores it and the parameter of the function in state variables.
	function acceptMoneyAndNumber(uint64 number) payable public {
		m_number = number;
		m_msg_value = msg.value;
	}
}
