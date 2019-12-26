pragma solidity ^0.5.0;

contract ICentralBank {
	function GetExchangeRate(uint16 code) public;
}

contract ICurrencyExchange {
	function setExchangeRate(uint32 n_exchangeRate) public;
}

// This contract implements 'ICurrencyExchange' interface.
// The contract calls remote bank contract to get the exchange rate via callback function calling.
contract CurrencyExchange is ICurrencyExchange {

	// Runtime function that allows contract to process inbound messages spending
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm_accept();
		_;
	}

	// State variable storing the exchange rate.
	uint32 exchangeRate;

	// This function gets an address of the contract and code of the currency <code>,
	// casts the address to IRemoteContract interface and calls
	// function 'GetExchangeRate' with parameter <code>.
	function updateExchangeRate(address bankAddress, uint16 code) public alwaysAccept {
		ICentralBank(bankAddress).GetExchangeRate(code);
	}

	// A callback function to set exchangeRate.
	function setExchangeRate(uint32 n_exchangeRate) public alwaysAccept {
		// save parameter n_exchangeRate in state variable 'exchangeRate'.
		exchangeRate = n_exchangeRate;
	}
}
