pragma solidity >= 0.6.0;

// Simple wallet contract which can perform an arbitrary transfer.
contract SimpleWallet {

    // id - some magic number
    uint m_id;
    // number of transactions
    uint transactionCounter;

    // Constructor function initializes the transaction counter.
    constructor(uint id) public {
        require(tvm.pubkey() != 0);
        tvm.accept();
        m_id = id;
        transactionCounter = 0;
    }

    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        _;
    }

    // Function to make an arbitrary transfer.
    function sendTransaction(address destination, uint128 value, bool bounce, uint8 flag) public onlyOwnerAndAccept {
        // Check that contract can perform specified transaction.
        require(value > 0 && value < address(this).balance, 101);

        // Check that the function was called by the owner.
        require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();

        // Perform transfer.
        destination.transfer(value, bounce, flag);

        //Increase the transaction counter.
        transactionCounter++;
    }

    /*
     * Public Getters
     */
    // Function to get state variables.
    function getData() public view returns (uint id, uint counter) {
        return (m_id, transactionCounter);
    }
}
