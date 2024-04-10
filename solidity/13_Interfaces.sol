pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

// Interface to the bank client.
interface IBankClient {
    function demandDebt(coins amount) external;
    function setDebtAmount(coins amount) external;
}

// Interface to the bank collector.
interface IBankCollector {
    function receivePayment() external;
    function getDebtAmount() external;
}
