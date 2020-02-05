# Remote procedure call

There are two contracts in this subdirectory - the sender and the receiver.
The sender has a method `sendTo` to call a method remoteMethod of the contract specified by the given address.
The receiver accepts the incoming message and stores the incoming value in value_persistent.

## Methods

### Method `sendTo` (`sender.c`)
#### Input values
##### Argument `remoteContractAddress`
* ABI type: `address`.
* C type: `MsgAddressInt`.
* Description: specifies the address of the contract to call.

#### Output values
None

#### Notes
Sends a message with value `42` encoded in body the public method `remoteProcedure` of the contract with a given address.
It's assumed that `remoteProcedure` takes a single uint64 value.

### Method `remoteProcedure` (`reciever.c`).
#### Input values
##### Argument `value`
* ABI type: `uint64`
* C type: `unsigned`
* Description: the incoming value.

#### Output values
None

#### Notes
Store the incoming value in value_persistent.

## Persistent data
### Field `value_persistent` (`callee.c`)
* C type: `unsigned`
* Description: the value received from the caller.
