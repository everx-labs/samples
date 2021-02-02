pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "13_Interfaces.sol";

// The contract allows to store information about bank clients and iterate over them to filter clients.
contract BankCollector is IBankCollector {

    // Expiration period.
    uint32 constant EXPIRATION_PERIOD = 1 days;

    // State variable storing client information.
    mapping(address => ClientInfo) clientDB;

    constructor() public {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    // Struct for storing the credit information.
    struct ClientInfo {
        uint debtAmount;
        uint32 expiredTimestamp;
    }

    // Add client to database.
    function addClient(address addr, uint debtAmount) public onlyOwner {
        // Mapping member function to obtain value from mapping if it exists.
        optional(ClientInfo) info = clientDB.fetch(addr);
        if (info.hasValue()) {
            ClientInfo i = info.get();
            i.debtAmount += debtAmount;
            clientDB[addr] = i;
        } else {
            clientDB[addr] = ClientInfo(debtAmount, now + EXPIRATION_PERIOD);
        }
    }

    // Function for client to get his debt amount.
    function getDebtAmount() public override {
        // Mapping member function to obtain value from mapping if it exists.
        optional(ClientInfo) info = clientDB.fetch(msg.sender);
        if (info.hasValue()) {
            IBankClient(msg.sender).setDebtAmount(info.get().debtAmount);
        } else {
            IBankClient(msg.sender).setDebtAmount(228);
        }
    }

    // Function for client to return debt.
    function receivePayment() public override {
        address addr = msg.sender;
        // Mapping member function to obtain value from mapping if it exists.
        optional(ClientInfo) info = clientDB.fetch(addr);
        if (info.hasValue()) {
            ClientInfo i = info.get();
            if (i.debtAmount <= msg.value) {
                delete clientDB[addr];
            } else {
                i.debtAmount -= msg.value;
                clientDB[addr] = i;
            }
        }
    }

    // Function to demand all expired debts.
    function demandExpiredDebts() public view onlyOwner {
        // Mapping member function to obtain minimal key and associated value from mapping if it exists.
        optional(address, ClientInfo) client = clientDB.min();
        while (client.hasValue()) {
            (address addr, ClientInfo info) = client.get();
            if (info.expiredTimestamp <= now)
                IBankClient(addr).demandDebt(info.debtAmount);
            // Mapping member function to obtain next key and associated value from mapping if it exists.
            client = clientDB.next(addr);
        }
    }
}
