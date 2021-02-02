pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "3_Loaner.sol";

// This contract calls the remote contract function with parameter to ask remote contract to transfer
//  <amount> of currency.
contract Borrower {

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	function askForALoan(Loaner loanerAddress, uint128 amount) public pure checkOwnerAndAccept {
		// Call the remote contract function with parameter.
		loanerAddress.borrow(amount);
	}
}
