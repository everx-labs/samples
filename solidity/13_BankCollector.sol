pragma solidity ^0.5.0;

// Interface to the bank client.
contract IBankClient {
        function demandDebt(uint amount) public;
}

// The contract allows to store information about bank clients and iterate over them to filter clients.
contract BankCollector {

	// Modifier that allows public function to accept all external calls.
	modifier onlyOwner {
                require (msg.pubkey() == tvm.pubkey(), 101);
		tvm.accept(); 	// Runtime function that allows contract to process inbound messages spending
				// it's own resources (it's necessary if contract should process all inbound messages,
				// not only those that carry value with them).
		_;
	}

	// Struct for storing the credit information.
	struct ClientInfo {
		uint debtAmount;
		uint32 expiredTimestamp;
	}

	// State variable storing client information.
	mapping(address => ClientInfo) clientDB;
        uint nextID;

        // Expiration period.
        uint32 constant EXPIRATION_PERIOD = 86400; // 1 day

        // Add client to database.
        function addClient(address addr, uint debtAmount) public onlyOwner {
                // Mapping member function to obtain value from mapping if it exists.
                (bool exists, ClientInfo memory info) = clientDB.fetch(addr);
                if (exists) {
                        info.debtAmount += debtAmount;
                        clientDB[addr] = info;
                } else {
                        clientDB[addr] = ClientInfo(debtAmount, uint32(now) + EXPIRATION_PERIOD);
                }
        }

        // Function for client to get his debt amount.
        function getDebtAmount() public payable returns (uint) {
                // Mapping member function to obtain value from mapping if it exists.
                (bool exists, ClientInfo memory info) = clientDB.fetch(msg.sender);
                if (exists) {
                        return info.debtAmount;
                }
                return 0;
        }

        // Function for client to return debt.
        function recievePayment() public payable {
                address addr = msg.sender;
                // Mapping member function to obtain value from mapping if it exists.
                (bool exists, ClientInfo memory info) = clientDB.fetch(addr);
                if (exists) {
                        if (info.debtAmount <= msg.value) {
                                delete clientDB[addr];
                        } else {
                                info.debtAmount -= msg.value;
                                clientDB[addr] = info;
                        }
                }
        }

        // Function to demand all expired debts.
        function demandExpiredDebts() public onlyOwner {
                uint32 curTime = uint32(now);
                // Mapping member function to obtain minmal key and associated value from mapping if it exists.
                (address addr, ClientInfo memory info, bool exists) = clientDB.min();
                while(exists) {
                        if (info.expiredTimestamp <= curTime)
                                IBankClient(addr).demandDebt(info.debtAmount);
                        // Mapping member function to obtain next key and associated value from mapping if it exists.
                        (addr, info, exists) = clientDB.next(addr);
                }
        }

}
