# Gram giver example

There are two contracts in this repository - the client and the giver.
The client requests grams by calling `requestGrams` method, specifying the address of the giver contract and the amount of grams it needs.
The giver receives the request in `getGrams` method and transfers grams to the sender.

## Methods

### Method `requestGrams` (`client.c`)
#### Input values
##### Argument `remoteContractAddress`
* ABI type: `address`.
* C type: `MsgAddressInt`.
* Description: specifies the address of the contract to call.

##### Argument `value`
* ABI type: `uint64`.
* C type: `unsigned`.
* Description: number of nanograms to be requested.

#### Output values
None

#### Notes
Sends a message with `value` encoded in body the public method `getGrams` of the contract with a given address.
It's assumed that `getGrams` takes a single uint64 value.

### Method `getGrams` (`giver.c`).
#### Input values
##### Argument `value`
* ABI type: `uint64`
* C type: `unsigned`
* Description: number of grams requested.

#### Output values
None

#### Notes
Sends `value` nanograms to the address where the incoming message came from.

## Persistent data
### Field `numCalls_persistent` (`client.c`)
* C type: `unsigned`
* Description: number of requests to giver.
