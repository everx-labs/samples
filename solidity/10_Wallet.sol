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

    // Runtime function that obtains sender's public key.
    function tvm_sender_pubkey() private pure returns (uint256) {}

    // Runctime function that obtains contract owner's public key.
    function tvm_my_public_key() private pure returns (uint256) {}

    // Runtime function that allows to make a transfer with arbitrary settings.
    function tvm_transfer(address payable addr, uint128 value, bool bounce, uint16 flags) private pure {}

    // Runtime function that allows contract to process inbound messages spending
    // it's own resources (it's necessary if contract should process all inbound messages,
    // not only those that carry value with them).
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
        owner = tvm_my_public_key();	// save contract's public key in the state variable.
    }


    /// @dev Allows to transfer grams to the destination account.
    /// @param dest Transfer target address.
    /// @param value Nanograms value to transfer.
    /// @param bounce Flag that enables bounce message in case of target contract error.
    function sendTransaction(address payable dest, uint128 value, bool bounce) public view checkOwnerAndAccept {
        require(value > 0 && value < address(this).balance, 101);
        tvm_transfer(dest, value, bounce, 0);
    }

}
