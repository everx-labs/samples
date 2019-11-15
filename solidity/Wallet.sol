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
      102 - invalid transfer value.
      103 - destination address is zero.
     */

    /*
     * Runtime functions
    */
    function tvm_sender_pubkey() private view returns (uint256) {}
    function tvm_my_public_key() private pure returns (uint256) {}
    function tvm_transfer(address payable addr, uint128 value, bool bounce, uint16 flags) private {}
    function tvm_accept() private pure {}
    function tvm_make_address(int8 wid, uint256 addr) private pure returns (address payable) {}

    modifier alwaysAccept {
        tvm_accept(); _;
    }

    /*
     * Public functions
     */

    /// @dev Contract constructor.
    constructor() public {
        owner = tvm_my_public_key();
    }

    /// @dev Allows to transfer grams to destination account.
    /// @param dest Transfer target address.
    /// @param value Nanograms value to transfer.
    function sendTransaction(address payable dest, uint128 value, bool bounce) public alwaysAccept {
        require(tvm_sender_pubkey() == owner, 100);
        require(value > 0 && value < address(this).balance, 102);
        require(dest != tvm_make_address(0,0), 103);
        tvm_transfer(dest, value, bounce, 0);
    }

}
