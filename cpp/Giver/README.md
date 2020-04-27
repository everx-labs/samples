# Giver

The example demonstrates how to asynchronously call a method of a contract from another contract.
Client contract asks for money from a giver one by calling its `give` method, which in turn calls `receive_and_report` method of the client.

## Methods
* `Client::get_money(lazy<MsgAddressInt> giver, uint_t<256> balance)` - calls `give` method of the contract deployed at `giver` address. Pass balance as the argument of the call.
* `Client::receive_and_report()` - send an external message displaying the balance of the incoming message.
* `Giver::give(uint_t<256> value)` - call `receive_and_report` method of the sender.
