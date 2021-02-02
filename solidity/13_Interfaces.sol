pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// Interface to the bank client.
interface IBankClient {
    function demandDebt(uint amount) external;
    function setDebtAmount(uint amount) external;
}

// Interface to the bank collector.
interface IBankCollector {
    function receivePayment() external;
    function getDebtAmount() external;
}
