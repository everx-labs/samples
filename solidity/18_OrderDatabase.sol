pragma ton-solidity >= 0.35.0;

import "18_Interfaces.sol";

// Contract that demonstrates usage of new mapping functions.
contract OrderDatabase is IOrderDatabase {

    // Struct to store order information.
    struct Order {
        address client;
        uint amount;
        uint32 orderDuration;
        uint32 createdAt;
    }

    // State variable storing database of orders.
    mapping (uint40 => Order[]) database;

    // Exception codes:
    uint constant MESSAGE_SENDER_IS_NOT_THE_OWNER = 101;
    uint constant MAPPING_REPLACE_ERROR = 102;
    uint constant PLAIN_TRANSFERS_ARE_FORBIDDEN = 103;
    uint constant NO_PUBKEY = 104;

    // Constructor function initializes the database with an array of orders.
    constructor(Order[] initialOrders, uint32 duration) public {
        require(tvm.pubkey() != 0, NO_PUBKEY);
        require(tvm.pubkey() == msg.pubkey(), MESSAGE_SENDER_IS_NOT_THE_OWNER);
        tvm.accept();
        uint40 key = now + duration;

        // Mapping function 'add(keyArg, valueArg)' sets the value associated with keyArg only if the keyArg does not exist in mapping.
        database.add(key, initialOrders);
    }

    // Modifier that allows function to accept calls only from the contract owner.
    modifier checkOwnerAndAccept {
        // Check that message was signed with contracts key.
        require(tvm.pubkey() == msg.pubkey(), MESSAGE_SENDER_IS_NOT_THE_OWNER);
        tvm.accept();
        _;
    }

    // Internal inline function that removes expired orders from the database.
    // Keyword 'inline' means that this function is not called but it's code is inserted in place of call.
    function removeExpiredOrders() inline private {
        // Mapping function 'prevOrEq(keyArg)' computes the maximal key in mapping that is lexicographically less or equal to argument keyArg
        // and returns that key, associated value and status flag.
        optional(uint40, Order[]) val = database.prevOrEq(now);

        while (val.hasValue()) {
            (uint40 expire, ) = val.get();
            // Remove entity from mapping.
            delete database[expire];

            // Obtain next array of expired orders.
            val = database.prevOrEq(now);
        }
    }

    // Public function to create an order.
    function createAnOrder(uint amount, uint32 duration) public override {
        // Remove expired orders.
        removeExpiredOrders();

        // Create new order.
        Order newOrder = Order(msg.sender, amount, duration, now);
		Order[] orders;
		orders.push(newOrder);

        // Calculate expiration timestamp.
		uint40 key = now + duration;

        // Mapping function 'getAdd(keyArg, valueArg)' sets the value associated with keyArg, but only if keyArg does not exist in
        // the mapping. Otherwise returns the old value without changing the dictionary.
		optional(Order[]) old_orders = database.getAdd(key, orders);
        if (old_orders.hasValue()) {
            Order[] orders_array = old_orders.get();
            orders_array.push(newOrder);

            // Mapping function 'replace(keyArg, valueArg)' sets the value associated with keyArg only if keyArg exists in mapping.
            bool status = database.replace(key, orders_array);

            // Throw exception in case of unexpected error.
            require(status, MAPPING_REPLACE_ERROR);
        }

        // Call callback function to send order key to the client.
        IClient(msg.sender).setOrderKey(key);
	}


    // Function to get the first not expired order.
    function getNextOrder() public checkOwnerAndAccept returns (bool exists, Order nextOrder) {
        // Remove expired transactions.
        removeExpiredOrders();

        // Obtain current timestamp.
        uint40 curTime = now;

        // Mapping function 'nextOrEq(keyArg)' computes the minimal key in mapping that is lexicographically greater or equal to argument keyArg
        // and returns that key, associated value and status flag.
        optional(uint40, Order[]) n_orders = database.nextOrEq(curTime);
        if (n_orders.hasValue()) {
            (uint40 expire, Order[] orders) = n_orders.get();
            // Get the last order from the array.
            nextOrder = orders[orders.length - 1];

            // Set the return flag. 
            exists = true;

            // Delete the las order from the array.
            orders.pop();

            if (orders.length == 0)
                // If the array is empty, remove entity from the mapping.
                delete database[expire];
            else
                // Replace value in the database.
                database.replace(expire, orders);
        }
    }

    // Function that allows owner to change the database.
    function setEntity(bool replace, uint40 key, Order[] newOrders)
        public
        checkOwnerAndAccept
        returns (bool status, Order[] oldOrders)
    {
        // Remove expired transactions.
        removeExpiredOrders();

        // 'replace' flag set means that owner wants to replace the value, if it is not set and key doesn't exist in the database
        // false status should be returned and database shouldn't be changed.
        if (replace) {
            // Mapping function 'getReplace(keyArg, valueArg)' sets the value associated with keyArg, but only if keyArg exists in
            // the mapping. On success returns the old value, otherwise returns a null value.
            optional(Order[]) orders = database.getReplace(key, newOrders);
            status = orders.hasValue();
            if (status) {
                oldOrders = orders.get();
            }
        } else {
            // If 'replace' is not set, contract just has to set the value and return the old value in case it existed.

            // Mapping function 'getSet(keyArg, valueArg)' sets the value associated with keyArg and returns the old value associated
            // with keyArg, if it exists, otherwise returns a null value.
            optional(Order[]) orders = database.getSet(key, newOrders);
            status = orders.hasValue();
            if (status) {
                oldOrders = orders.get();
            }
        }
    }

}
