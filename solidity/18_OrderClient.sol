pragma solidity >= 0.6.0;

import "18_Interfaces.sol";

// Contract that can create new orders in OrderDatabase contract.
contract Client is IClient {

    // State variables:
    uint40 orderKey;    // Key of the last order in database.
    uint counter;       // Internal order counter.
    address database;

    constructor(address _database) public {
        require(tvm.pubkey() != 0);
        tvm.accept();
        database =  _database;
    }

    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        _;
    }

    modifier onlyDatabase {
        require(msg.sender == database);
        _;
    }

    // Function that calls database to create an order.
    function createAnOrder(uint amount, uint32 duration) public onlyOwnerAndAccept {
        IOrderDatabase(database).createAnOrder{value: 1 ton}(amount, duration);
        counter++;
    }

    // Callback function to set key of the last order.
    function setOrderKey(uint40 key) public override onlyDatabase {
        orderKey = key;
    }

    /*
     * Public Getters
     */
    // Getter function to obtain the state variables.
    function getData() public view returns (uint40 order, uint qty) {
        return (orderKey, counter);
    }
}
