# Wallet

This contract has two methods. The first method (`constructor`)
has no formal parameters, but gets public signature of the message (using
tvm_sender_pubkey() function), and stores it in a persistent variable.

The second method (`sendTransaction`) transfers the specified
amount of money from the account to another account.

This contract demonstrates work with public signatures of the messages;
also this is a direct analog of Wallet contract in Solidity.

## Methods

### Method `constructor`
#### Input values
None

#### Output values
None

#### Notes
This method initializes the contract with the public signature of the
message: if the signature is absent (equals to zero), the method throws
an exception. Otherwise, the signature owner becomes the owner of the
wallet.

If the contract is already initialized (owner_persistent field is
not zero, that is populated), the method throws an exception.

### Method `sendTransaction`
#### Input values
##### Argument `dest`
* ABI type: `uint256`
* C type: `unsigned`
* Description: specifies destination account for funds transfer

##### Argument `value`
* ABI type: `uint128`
* C type: `unsigned`
* Description: money (in nanograms) to be transferred

##### Argument `bounce`
* ABI type: `uint1`
* C type: `unsigned`
* Description: flags that the transfer message should bounce, if the
destination account does not exist.

#### Output values
None

#### Notes
This method transfers `value` nanograms from the contract to the 
`dest` account. Various conditions are checked, among them:
- the account balance should greater than `value`;
- the message should be signed by the wallet owner.

## Persistent data
### Field `owner_persistent`
* C type: `unsigned`
* Description: keeps the contract owner signature. 
