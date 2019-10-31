pragma solidity ^0.5.0;

contract IRemoteContract {
	function acceptMoneyAndNumber(uint64 number) payable public;
}

contract MyContract {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	uint64 m_result;

	function sendMoneyAndNumber(address anotherContract, uint64 number) public alwaysAccept {
		IRemoteContract(anotherContract).acceptMoneyAndNumber.value(3000000)(number);
		return;
	}
}
