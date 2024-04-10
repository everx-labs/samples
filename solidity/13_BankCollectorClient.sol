pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

import "13_Interfaces.sol";

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {

    address public bankCollector;
    uint public debtAmount;

    constructor(address _bankCollector) {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        bankCollector = _bankCollector;
    }

    // Modifier that allows public function to be called only by message signed with owner's pubkey.
    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
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

    function demandDebt(coins amount) external override onlyCollector {
        IBankCollector(msg.sender).receivePayment{value: amount}();
    }

    function obtainDebtAmount() external view onlyOwnerAndAccept {
        IBankCollector(bankCollector).getDebtAmount{value: 0.5 ever}();
    }

    function setDebtAmount(coins amount) external override onlyCollector {
        debtAmount = amount;
    }
}
