pragma solidity ^0.5.0;

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

    /*
     * Runtime functions
    */
    // Function to obtain inbound message's signification public key.
    function tvm_sender_pubkey() private pure returns (uint256) {}

    // Function to obtain the contract's owner public key.
    function tvm_my_public_key() private view returns (uint256) {}

    // Function to make an arbitrary currency transfer.
    function tvm_transfer(address payable addr, uint128 value, bool bounce, uint16 flags) private pure {}

    // Function to accept inbound messages.
    function tvm_accept() private pure {}

    // Modifier that allows function to accept external call only if it was signed
    // with contract owner's public key.
    modifier checkOwnerAndAccept {
        require(tvm_sender_pubkey() == owner, 100);
        tvm_accept();
        _;
	}

    /*
     * Public functions
     */

    /// @dev Contract constructor.
    constructor() public {
        owner = tvm_my_public_key();	// save contract's public key in a state variable.
    }


    /// @dev Allows to transfer grams to destination account.
    /// @param dest Transfer target address.
    /// @param value Nanograms value to transfer.
    /// @param bounce Flag that enables bounce message in case of target contract error.
    function sendTransaction(address payable dest, uint128 value, bool bounce) public view checkOwnerAndAccept {
        require(value > 0 && value < address(this).balance, 101);
        tvm_transfer(dest, value, bounce, 0);
    }

}
