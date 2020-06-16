pragma solidity >=0.5.0;

/// @title Simple wallet
/// @author Tonlabs
contract Wallet {
    /*
     *  Storage
     */
    uint256 owner;

    /*
     Exception codes:
      100 - message sender is not a wallet owner.
      101 - invalid transfer value.
     */

    // Modifier that allows function to accept external call only if it was signed
    // with contract owner's public key.
    modifier checkOwnerAndAccept {
        // Check that inbound message was signed with owner's public key.
        // Runtime function that obtains sender's public key.
        require(msg.pubkey() == owner, 100);

		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

    /*
     * Public functions
     */

    /// @dev Contract constructor.
    constructor() public {
        tvm.accept();
        // save contract's public key in the state variable.
        // Runtime function that obtains contract owner's public key.
        owner = tvm.pubkey();
    }


    /// @dev Allows to transfer grams to the destination account.
    /// @param dest Transfer target address.
    /// @param value Nanograms value to transfer.
    /// @param bounce Flag that enables bounce message in case of target contract error.
    function sendTransaction(address dest, uint128 value, bool bounce) public view checkOwnerAndAccept {
        require(value > 0 && value < address(this).balance, 101);
         // Runtime function that allows to make a transfer with arbitrary settings.
        dest.transfer(value, bounce, 0);
    }

}
