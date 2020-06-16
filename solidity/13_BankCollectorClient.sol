pragma solidity >=0.5.0;

// Interface to the bank client.
abstract contract IBankClient {
        function demandDebt(uint amount) public virtual;
        function setDebtAmount(uint amount) public virtual;
}

// Interface to the bank collector.
abstract contract IBankCollector {
        function receivePayment() public  virtual;
        function getDebtAmount() public virtual;
}

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {

        address bankCollector;
        uint debtAmount;

    // Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

        constructor(address _bankCollector) public alwaysAccept {
		bankCollector = _bankCollector;
	}

    // Modifier that allows public function to accept external calls only from bank collecor.
	modifier onlyCollector {
        // Runtime function to obtain message sender address.
		require(msg.sender == bankCollector, 101);

		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

        function demandDebt(uint amount) public override onlyCollector {
                IBankCollector(msg.sender).receivePayment.value(amount)();
        }

        function obtainDebtAmount() public alwaysAccept {
                IBankCollector(bankCollector).getDebtAmount.value(500000000)();
        }

        function setDebtAmount(uint amount) public override onlyCollector {
                debtAmount = amount;
        }

        function getDebtAmount() public view alwaysAccept returns (uint) {
                return debtAmount;
        }

}
