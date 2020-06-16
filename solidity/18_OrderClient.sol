pragma solidity >= 0.6.0;

// Interface of the database contract.
interface OrderDatabase {
    function createAnOrder(uint amount, uint32 duration) external;
}

// Contract that can create new orders in OrderDatabase contract.
contract Client {

    // State variables:
    uint40 orderKey;    // Key of the last order in database.
    uint counter;       // Internal order counter.

    // Modifier that allows function to accept all inbound calls.
    modifier alwaysAccept {
        tvm.accept();
        _;
    }

    // Getter function to obtain the state variables.
    function getData() public view alwaysAccept returns (uint40, uint) {
        return (orderKey, counter);
    }

    // Function that calls database to create an order.
    function createAnOrder(address database, uint amount, uint32 duration) public alwaysAccept {
        OrderDatabase(database).createAnOrder{value:200000000}(amount, duration);
        counter++;
    }

    // Callback function to set key of the last order.
    function setOrderKey(uint40 key) public alwaysAccept {
        orderKey = key;
    }
}
