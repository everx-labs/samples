pragma ever-solidity >= 0.35.0;
pragma AbiHeader expire;

/// @title Simple wallet
/// @author Tonlabs
contract Wallet {
    /*
     * Exception codes:
     * - 100: the message creator (tx signer, `msg.pubkey`) is not the wallet owner (`tvm.pubkey`)
     * - 101: the wallet owner (stored in `tvm.pubkey`, part of state init) is not set up properly
     */

    /// @dev Contract constructor
    constructor() {
        // Check the contract owner (`tvm.pubkey`) is set up properly (is not zero)
        require(tvm.pubkey() != 0, 101);

        // Check the message has a signature (`msg.pubkey` is not zero) and the message sender
        //   (tx signer, `msg.pubkey`) is the contract owner (`tvm.pubkey`)
        require(msg.pubkey() == tvm.pubkey(), 100);

        // Needed for initialization to be possible by an external inbound message
        tvm.accept();
    }

    /// @dev Modifier that allows a function to accept an external inbound call only
    ///   if it was signed with the contract owner's public key
    modifier checkOwnerAndAccept {
        // Check that the inbound message was signed with the owner's public key
        require(msg.pubkey() == tvm.pubkey(), 100);

		// Runtime function that allows the contract to process external messages spending
		// its own resources (it's necessary if the contract should process external messages,
		// not only those that carry value with them)
		tvm.accept();

        // Function body execution
		_;
	}

    /// @dev Allows transferring tons to the destination account
    /// @param dest Transfer target address
    /// @param value Nanoevers value to transfer
    /// @param bounce Flag that enables a bounce message in case of the target contract error
    function sendTransaction(address dest, uint128 value, bool bounce) public view checkOwnerAndAccept {
        // Runtime function that allows making a transfer with arbitrary settings
        // Flag is hardcoded to `2` in order to avoid
        //   [Tx Replay Attack](https://everscale.guide/smart_contracts/replay_protection)
        dest.transfer(value, bounce, 2);
    }
}
