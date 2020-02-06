pragma solidity ^0.5.0;

// Interface to the bank client.
contract IBankClient {
        function demandDebt(uint amount) public;
}

// Interface to the bank collector.
contract IBankCollector {
        function recievePayment() public payable {}
}

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {
        function demandDebt(uint amount) public {
                IBankCollector(msg.sender).recievePayment.value(amount)();
        }
}
