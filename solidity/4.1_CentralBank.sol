pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This contract implements 'IBank' interface.
contract CentralBank {

	// This function receives the code of currency and returns to the sender exchange rate
	// via callback function.
	function getExchangeRate(uint16 currency) public pure responsible returns (uint32) {
		// To convert one currency to another we just multiply by 16. Here maybe more complex logic.
		uint32 ec = 16 * uint32(currency);
		return{value: 0, flag: 64} ec;
		// options {value: 0, flag: 64} mean returning change
	}

}
