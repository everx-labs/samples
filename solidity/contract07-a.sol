pragma solidity ^0.5.0;

contract IRemoteContract {
	function acceptMoneyAndNumber(uint64 number) payable public;
}

contract MyContract {

	uint64 m_result;

	function sendMoneyAndNumber(address anotherContract, uint64 number) public {
		IRemoteContract(anotherContract).acceptMoneyAndNumber.value(3000000)(number);
		return;
	}
}
