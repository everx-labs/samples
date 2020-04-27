# Piggybank

This example demonstrate message exchange between contracts.
* `Piggybank` is the contract which accumulate savings.
* `PiggyStranger` is the contract that can only deposit grams to `Piggybank`.
* `PiggyOwner` is the contract that can deposit grams to `Piggybank` and withdraw all the saving when the saving goal is reached.

## Methods
The contract has the following methods:
* `Piggybank::constructor(lazy<MsgAddressInt> owner, uint_t<256> limit)` - method run on the contract's deploy. It stores an address of the contract which is treated as PiggyOwner. It also stores goal for saving money (`limit`).
* `Piggybank::deposit()`. The method is supposed to be called by any contract (in particular `PiggyOwner` or `PiggyStranger`) to contribute to savings. Unlike a simple incoming message with balance, deposit call count the incoming money towards the saving goal.
* `Piggybank::withdraw()`. The method is supposed to be called by the owner contract, otherwise the exception is thrown. If saving reach the goal, send them to the caller.
* `Piggybank::get_balance()` - show the current amount of savings.
* `PiggyOwner::deposit(lazy<MsgAddressInt> bank, uint_t<256> balance)`. Call `deposit` method of the contract deployed at `bank` address (the contract is expected to be `Piggybank`) and send `balance` nanograms to it.
* `Piggybank::withdraw(lazy<MsgAddressInt> bank)`. Call `withdraw` method of the contract deployed at `bank` address (the contract is expected to be `Piggybank`).
* `PiggyStranger::deposit(lazy<MsgAddressInt> bank, uint_t<256> balance)`. Call `deposit` method of the contract deployed at `bank` address (the contract is expected to be `Piggybank`) and send `balance` nanograms to it.
