pragma solidity >=0.6.0;
pragma AbiHeader expire;


contract SimpleContract {

	uint m_a;
	uint32 m_b;

	constructor(uint a, uint32 b) public {
		require(tvm.pubkey() != 0);
		tvm.accept();
		m_a = a;
		m_b = b;
	}

	/*
	 * Public Getters
	 */
	function getData() public returns (uint a, uint32 b) {
		a = m_a;
		b = m_b;
	}
}
