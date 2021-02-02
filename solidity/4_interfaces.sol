pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface ICentralBank {
	function getExchangeRate(uint16 code) external;
}

interface ICurrencyExchange {
	function setExchangeRate(uint32 n_exchangeRate) external;
}