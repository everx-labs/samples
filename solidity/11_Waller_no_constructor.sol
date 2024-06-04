pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

contract Wallet {

	uint m_counter;
	uint m_receiveCounter;
	address static m_creator;

	modifier checkOwnerAndAccept {
		require(msg.sender == m_creator, 100);
		tvm.accept();
		_;
	}

	function sendCoins(address dest, coins value, bool bounce) external checkOwnerAndAccept {
		++m_counter;
		dest.transfer(value, bounce, 0);
	}

	receive() external {
		++m_receiveCounter;
	}
}
