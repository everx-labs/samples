pragma solidity >= 0.6.0;

// Simple wallet contract which can perform an arbitrary transfer.
contract SimpleWallet {

    // Fallback, receive and onBounce functions are defined, because this contract should be able to receive plain transfers and
    // bounced messages.
    fallback() external payable {}
    receive() external payable {}
    onBounce(TvmSlice /*slice*/) external payable {}

    // State variable to store number of transactions.
    uint transactionCounter;

    // Constructor function initializes the transaction counter.
    constructor(uint counter) public {
        tvm.accept();
        transactionCounter = counter;
    }

    // Function to make an arbitrary transfer.
    function sendTransaction(address payable destination, uint128 value, bool bounce, uint8 flag) public {
        // Check that contract can perform specified transaction.
        require(value > 0 && value < address(this).balance, 101);

        // Check that the function was called by the owner.
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();

        // Perform transfer.
        destination.transfer(value, bounce, flag);

        //Increase the transaction counter.
        transactionCounter++;
    }

}
