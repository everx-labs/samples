## Solidity contract workflow

Start with source code of the contract in \<MyContract.sol\>

1) Compile Solidity source to TVM assembler: 
```

solc --tvm MyContract.sol > MyContract.code

```

2) Generate public interface for the contract in JSON format: 
```

solc --tvm_abi MyContract.sol > MyContract.abi.json

```

3) Assemble and link with libraries of your choice into TVM bytecode: 
```

tvm_linker compile MyContract.code --lib <path to>/stdlib_sol.tvm --abi-json MyContract.abi.json

```

Binary code of your contract is recorded into \<MyContractAddress\>.tvc file, where 
\<MyContractAddress\> is the address of the contract.
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
"Calling public function \<myFunction\> of the contract \<MyContract\> with an argument name \<parameter\> of type \<type\>."
is expressed as "Call \<MyContract\>.\<myFunction\>(\<type\> \<parameter\>)".

## Contract examples

[contract 01](https://github.com/tonlabs/samples/blob/master/solidity/contract01.sol): persistent storage

Smart-contracts deployed to the blockchain store their state variables in a persistent storage.
Call "Test01.main(uint32 a)". It adds "a" to its state variable "m_accumulator", then records the result to "m_accumulator".
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
A contract owner is supposed to call the setAllowance() external method to specify limits. It also processes getCredit() internal messages and sends the allowed loan amount in response.
RemoteContract ([contract06-b](https://github.com/tonlabs/samples/blob/master/solidity/contract06-b.sol)) is a client that makes a loan request. It can take getMyCredit() external requests, forward those to a specified IMyContract type account and store the answer in a m_answer member field.

## Contract deployment

Here we describe \<MyContract.sol\> deployment onto the TON Blockchain Test Network (testnet) using Lite Client.

### 1) Compilation
Compile and link the Solidity source file to TVM bytecode as described above:
```
solc --tvm MyContract.sol > MyContract.code
solc --tvm_abi MyContract.sol > MyContract.abi.json
tvm_linker compile MyContract.code -w 0 --lib <path_to>/stdlib_sol.tvm --abi-json MyContract.abi.json [--genkey <path_to_save_keyfile>]
```

Notice that we've added argument "-w 0" to the tvm_linker, where "0" - is the id of workchain (default is -1).
By default tvm\_linker compiles contract with zero key, so we can add argument "--genkey <path_to_save_keyfile>" to generate new keypair for the contract and save it to the file.
If we already have a keypair, we can use existing pair with argument "--setkey <path_to_keyfile>".
The last command of the list above prints all possible addresses of the contract:
```
Saved contract to file <MyContractAddress>.tvc
testnet:
Non-bounceable address (for init): <MyContractNonBounceTestAddress>
Bounceable address (for later access): <MyContractBounceTestAddress>
mainnet:
Non-bounceable address (for init): <MyContractNonBounceMainAddress>
Bounceable address (for later access): <MyContractBounceMainAddress>
```

Save the output, we will need some of the addresses later.

### 2) Constructor message generation
We use tvm_linker to create a constructor message that we will send to deploy the contract to the testnet:

```
tvm_linker message <MyContractAddress> --init -w 0 [--setkey <path_to_keyfile>]
```

Here we also use an argument "-w" to set the workchain id and argument "--setkey" with keyfile generated on **step 1** to sign the message.
The command generates **.boc** file with name \<\*-msg-init.boc\>.

### 3) Account preparation
Out contract is going to store its code and data in the blockchain, but it costs money. So we must transfer some grams to our future contract address before deploying the contract. For transfer use one of the addresses obtained on the **step 1**. 

### 4) Contract deployment
When we have a constructor message **.boc** file for the contract and we have replenished the balance of the address we are going deploy to, we can run the Lite Client with [configuration file for the TON Blockchain Test Network](https://test.ton.org/ton-lite-client-test1.config.json):
```
lite-client -C ton-lite-client-test1.config.json
```

We can check whether the balance replenishment was successful: 
```
getaccount 0:<MyContractAddress>
```

We use "0" as the workchain id in the command above. If everything is OK, you will see an output containing similar data: 
```
           value:(currencies
             grams:(nanograms
               amount:(var_uint len:5 value:5000000000))
```

It means that we have some grams on the balance and can deploy the contract:
```
sendfile <path_to_file_<*-msg-init.boc>>
```

<*-msg-init.boc> is the file we obtained on the **step 2**.
After that we can check the account again and see, that the output now contains the state of the contract:
```
getaccount 0:<MyContractAddress>
```

### 5) Contract function call
To call a function of the contract we should prepare a special message and then send it to the testnet:
```
tvm_linker message <MyContractAddress> -w 0 --abi-json MyContract.abi.json --abi-method '<FunctionName>' --abi-params '{<FunctionArguments>}' [--setkey <path_to_keyfile>]
```

\'\{\<FunctionArguments\>\}\' should have the folowing form: \'\{"<Argument1_Name>":"Argument1_Value", "<Argument2_Name>":"Argument2_Value", ... \}\'
The command above will create a .boc file which we should send to the testnet as it was described on **step 4**.
