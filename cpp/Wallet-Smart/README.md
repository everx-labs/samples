# Wallet

This example is a simple wallet contract which allows to transfer grams to the specified address. Only the wallet's owner and optionaly thusted 3rd party contract is allowed to do such a transfer.

## Methods
This contract has four methods.
* `Wallet::constructor()` - method run on the contract's deploy, store the owner's key in the persistent storage.
* `Wallet::set_subscription(MsgAddressInt address)` - specify the address of the trusted contract, thus grant to the contract authority to send money.
* `MsgAddress Wallet::get_subscription()` - get subscription contract address.
* `Wallet::send_transaction(MsgAddressInt dest, uint128 value, bool bounce)` - send `value` nanograms to address `dest`.

## Persistent data
* uint256 `owner` - contract's owner public key.
* MsgAddressInt `subscription` - subscription contract address.
* uint64 `timestamp` - last timestamp value for replay protection check (hidden).
