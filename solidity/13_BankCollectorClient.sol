pragma solidity >=0.5.0;

// Interface to the bank client.
abstract contract IBankClient {
        function demandDebt(uint amount) public virtual;
}

// Interface to the bank collector.
abstract contract IBankCollector {
        function recievePayment() public payable  virtual;
}

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {
        function demandDebt(uint amount) public override {
                IBankCollector(msg.sender).recievePayment.value(amount)();
        }
}
