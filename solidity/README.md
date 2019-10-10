## Solidity contract workflow

Start with source code of the contract in <MyContract.sol>

1) Compile Solidity source to TVM assembler: 
```

solc --tvm MyContract.sol >MyContract.code

```
2) Generate public interface for the contract in JSON format: 
```

solc --tvm_abi MyContract.sol >MyContract.abi.json

```

3) Assemble and link with libraries of your choice into TVM bytecode: 
```

tvm_linker compile MyContract.code --lib <path to>stdlib_sol.tvm --abi-json MyContract.abi.json

```

Binary code of your contract is recorded into <MyContractAddress>.tvc file, where 
<MyContractAddress> is the address of the contract.
Contract is ready to be deployed onto local node or blockchain.

NB: You can test your contracts locally without even starting node:
```

tvm_linker test <MyContractAddress> --abi-json <MyContract.abi.json> --abi-method <"myMethod"> --abi-params '{"parameter":"value"}'

```
This set of smart-contract samples illustrates common functionality of smart-contracts developed in Solidity,
starting with very basic and gradually evolving into code snippets which may come handy in production smart-contracts.

Interaction with the contract in each of the samples described below starts with calling one of its public functions
with parameters. 
In the descriptions below :
"Calling public function <myFunction> of the contract <MyContract> with an argument name <parameter> of type <type>."
is expressed as "Call <MyContract>.<myFunction(<type> <parameter>)"

## Contract examples
           
[contract 01](https://github.com/tonlabs/samples/blob/master/solidity/contract01.sol): persistent storage

Smart-contracts deployed to the blockchain store their state variables in a persistent storage.
Сall "Test01.main(uint32 a)". It adds "a" to its state variable "m_accumulator", then records the result to "m_accumulator".
Resulting state of the account can be examined by conventional means.

[contract 02](https://github.com/tonlabs/samples/blob/master/solidity/contract02-a.sol): calling another [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract02-b.sol)

Contracts can call other remote contracts too. 	Call "MyContract.method(uint anotherContract)". Invokes public function of another contract. 
The remote contract (contract02-b) saves the integer value of the argument in its state variable.

[contract 03](https://github.com/tonlabs/samples/blob/master/solidity/contract03-a.sol): doing both at once

Call "MyContract.method(uint anotherContract)" combines work of examples 1 and 2. 
Calls a remote [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract03-b.sol) which records the call and saves the address of the caller in its state variable.

[contract 04](https://github.com/tonlabs/samples/blob/master/solidity/contract04-a.sol): gram transfer

This sample demonstrates how Gram transfer works. Call "MyContract.method(uint anotherContract, uint amount)". 
This requests <amount> of Grams from the contract deployed at the specified address. 
The remote contract ([contract04-b](https://github.com/tonlabs/samples/blob/master/solidity/contract04-b.sol)) transfers <amount> of Grams to the caller via **msg.sender.transfer(value)**.
Both contracts keep record of the number of transactions performed by bumping transaction counter and storing it in the persistent memory.

[contract 05](https://github.com/tonlabs/samples/blob/master/solidity/contract05-a.sol): callback implementation

Call "MyContract.method(address anotherContract, uint16 x)". Calls "RemoteContract.remoteMethod(uint16 x)"
The remote [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract05-b.sol) obtains caller's address via **msg.sender**, stores it in its state variable, and calls back.

[contract06](https://github.com/tonlabs/samples/blob/master/solidity/contract06-a.sol): loan amount approval

Call "MyContract.setAllowance(address anotherContract, uint64 amount)".
MyContract (contract06-a) stores information about loan allowances for different contracts. This data is recorded in the following field:
mapping(address => ContractInfo) m_allowed;
A contract owner is supposed to call the setAllowance() external method to specify limits. It also proccesses getCredit() internal messages and sends the allowed loan amount in response.
RemoteContract ([contract06-b](https://github.com/tonlabs/samples/blob/master/solidity/contract06-b.sol)) is a client that makes a loan request. It can take getMyCredit() external requests, forward those to a specified IMyContract type account and store the answer in a m_answer member field.
