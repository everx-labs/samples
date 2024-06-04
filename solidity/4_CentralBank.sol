pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;
import "4_interfaces.sol";

// This contract implements 'IBank' interface.
contract CentralBank is ICentralBank {

	constructor () {
		tvm.accept();
	}

	// This function receives the code of currency and returns to the sender exchange rate
	// via calling a callback function.
	function getExchangeRate(uint16 currency) external override {
		// Cast address of caller to ICurrencyExchange interface and call its 'setExchangeRate' function.
		// To convert one currency to another we just multiply by 16. Here maybe more complex logic.
		ICurrencyExchange(msg.sender).setExchangeRate(16 * currency);
	}

}
