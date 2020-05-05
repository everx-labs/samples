# Kamikaze

The example demonstrates how a contract can be destroyed.
To change the code of a deployed contract one can call `tvm_setcode` method and pass a cell with new code to it. In particular if to pass an empty cell, the contract will be destroyed.

## Methods
This contract has three methods.
* `Kamikaze::constructor()` - method run on the contract's deploy, store the owner's key in the persistent storage.
* `Kamikaze::selfDestruct(lazy<MsgAddressInt> addr)` - send outstanding balance to the specified address and destoy itself.

## Persistent data
* uint256 `owner` - contract's owner key.
