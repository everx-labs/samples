# Piggybank

This contract has two methods. The first method (`initialize_target`)
specifies the target amount of money that should be collected by
the contract.

The second method (`transfer`) transfers almost all the money from 
the account (reduced by fixed `MESSAGE_COST` amount, a fixed constant in
the contract C file) when the contract accumulates the target amount of money or more.

## Methods

### Method `initialize_target`
#### Input values
##### Argument `target`
* ABI type: `uint64`
* C type: `unsigned`
* Description: specifies target amount of money.

#### Output values
None

#### Notes
This method initializes the contract with the target amount of money.
The method may be called again with a greater target amount to
increase it. However, if the new target amount is smaller than the
previous one, the method will fail.

### Method `transfer`
#### Input values
##### Argument `destination_account`
* ABI type: `uint256`
* C type: `unsigned`
* Description: specifies the account for funds transfer.

#### Output values
None

#### Notes
This method transfers all funds from the contract (minus technical `MESSAGE_COST`,
needed to pay for the money transfer and the contract execution) to the specified
destination account.

## Persistent data
### Field `target_persistent`
* C type: `unsigned`
* Description: keeps the target amount of money. This amount may not be smaller than
`MESSAGE_COST`.
