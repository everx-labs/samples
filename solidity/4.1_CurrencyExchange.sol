pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

import "4.1_CentralBank.sol";

// This contract implements 'ICurrencyExchange' interface.
// The contract calls remote bank contract to get the exchange rate via callback function calling.
contract CurrencyExchange {

	// State variable storing the exchange rate.
	uint32 public exchangeRate;

	constructor() {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// This function gets an address of the contract and code of the currency <code>,
	// casts the address to IRemoteContract interface and calls
	// function 'GetExchangeRate' with parameter <code>.
	function updateExchangeRate(address bankAddress, uint16 currency) external view checkOwnerAndAccept {
		CentralBank(bankAddress).getExchangeRate{value: 1 ever, callback: CurrencyExchange.setExchangeRate}(currency);
	}

	// A callback function to set exchangeRate.
	function setExchangeRate(uint32 er) external {
		// save parameter er in state variable 'exchangeRate'.
		exchangeRate = er;
	}
}
