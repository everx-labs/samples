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
      101 - limit is overrun.
      102 - invalid transfer value.
      103 - destination address is zero.
     */

    /*
     * Runtime functions
    */
    function tvm_sender_pubkey() private view returns (uint256) {}
    function tvm_transfer(address payable addr, uint128 value, bool bounce, uint16 flags) private {}

    /*
     * Public functions
     */

    /// @dev Contract constructor.
    constructor() public {
        owner = tvm_sender_pubkey();
    }

    /// @dev Allows to transfer grams to destination account.
    /// @param dest Transfer target address.
    /// @param value Nanograms value to transfer.
    function sendTransaction(address payable dest, uint128 value, bool bounce) public {
        require(tvm_sender_pubkey() == owner, 100);
        require(value > 0 && value < address(this).balance, 102);
        require(dest != address(0), 103);
        tvm_transfer(dest, value, bounce, 0);
    }

}
