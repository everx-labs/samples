# Wallet

## Methods
This contract has four methods.
* `Wallet::init()` - initialization of contract.
* `Wallet::set_subscription(MsgAddress address)` - set subscription address.
* `MsgAddress Wallet::get_subscription()` - get subscription address.
* `Wallet::send_transaction(MsgAddressInt dest, uint128 value, bool bounce)` - send `value` nanograms to address `dest`.

## Persistent data
* uint256 `owner` - contract's owner, initialized in `Wallet::init()` call.
* MsgAddress `subscription` - subscription address.
* uint64 `timestamp` - last timestamp value for replay protection check.

