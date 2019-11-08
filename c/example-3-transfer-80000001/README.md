# Transfer 80000001

This contract sends 0xAAAA nanograms (43960 in decimal) to 0x80000001 account number hardcoded in the contract.
This contract shows how to create and send internal messages.

## Methods

### Method `compute`
#### Input values
None

#### Output values
None

#### Notes
This method does not return any values, so it does not send external
messages. However, it sends an internal message to 0x80000001 account.
In order to properly test its execution, one can check balance of
 0x80000001 account before and after the method invocation.

When the method is called for the first time for a specific node, the 0x80000001 account is likely to be nonexistent. In this case this message creates the account with about 0xAAAA nanograms
on the balance (a bit less,  since message transfer is not free).

To check that, use the `getaccount` command of test-lite-client (unluckily,
you cannot skip these 56 leading zeroes):

     getaccount 0:0000000000000000000000000000000000000000000000000000000080000001

## Persistent data
None
