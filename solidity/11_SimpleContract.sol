pragma solidity >=0.6.0;
pragma AbiHeader expire;


contract SimpleContract {

	uint m_a;
	uint32 m_b;

	constructor(uint a, uint32 b) public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);

		// NOTE: To protect from deploying this contract by hacker it's good idea to check msg.sender. See 17_SimpleWallet.sol
		tvm.accept();
		m_a = a;
		m_b = b;
	}

	/*
	 * Public Getters
	 */
	function getData() public view returns (uint a, uint32 b) {
		a = m_a;
		b = m_b;
	}
}
