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

3) Assemble and link with necessary libraries into TVM bytecode: 
```
tvm_linker compile MyContract.code --lib <path to>/stdlib_sol.tvm --abi-json MyContract.abi.json
```

The binary code of your contract is recorded into \<MyContractAddress\>.tvc file, where 
\<MyContractAddress\> is the address of the contract.
The contract is ready for deploy to the local node or blockchain.

NB: You can test your contracts locally without even starting node:
```
tvm_linker test <MyContractAddress> --abi-json <MyContract.abi.json> --abi-method <"myMethod"> --abi-params '{"parameter":"value"}'
```

## Contract examples

This set of smart-contract samples illustrates common functionality of smart-contracts developed in Solidity,
starting with very basic and gradually evolving into code snippets which may come handy in production smart-contracts.

Interaction with the contract in each of the samples described below starts with calling one of its public functions
with parameters. 
In the descriptions below :
"Calling public function \<myFunction\> of the contract \<MyContract\> with an argument name \<parameter\> of type \<type\>."
is expressed as "Call \<MyContract\>.\<myFunction\>(\<type\> \<parameter\>)".

[contract 01](https://github.com/tonlabs/samples/blob/master/solidity/contract01.sol): persistent storage

Smart-contracts deployed to the blockchain store their state variables in a persistent storage.
Call "Accumulator.add(uint value)". It adds "value" to its state variable "sum".
Resulting state of the account can be examined by conventional means.

[contract 02](https://github.com/tonlabs/samples/blob/master/solidity/contract02-a.sol): calling another [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract02-b.sol)

Contracts can also call other remote contracts. Call "MyContract.method(uint anotherContract) to invoke a public function of another contract.
The remote contract (contract02-b) saves the integer value of the argument and the caller address in its state variables.

[contract 03](https://github.com/tonlabs/samples/blob/master/solidity/contract03-a.sol): gram transfer

This sample demonstrates how Gram transfer works. Call "MyContract.method(address anotherContract, uint amount)". 
This requests \<amount\> of Grams from the contract deployed at the specified address. 
The remote contract ([contract03-b](https://github.com/tonlabs/samples/blob/master/solidity/contract03-b.sol)) transfers \<amount\> of Grams to the caller via **msg.sender.transfer(value)**.
Each contract has an internal transaction counter. The counter value is increased after each transaction and stored in the persistent memory.

[contract 04](https://github.com/tonlabs/samples/blob/master/solidity/contract04-a.sol): callback implementation

Call "MyContract.method(address anotherContract, uint16 x)". This function allows interacting with a remote contract by calling its function: "RemoteContract.remoteMethod(uint16 x)".
The remote [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract04-b.sol) obtains caller's address via **msg.sender**, stores it in its state variable, and performs a callback.

[contract05](https://github.com/tonlabs/samples/blob/master/solidity/contract05-a.sol): loan amount approval

Call "MyContract.setAllowance(address anotherContract, uint64 amount)".
MyContract (contract05-a) stores information about loan allowances for different contracts. This data is recorded in the following state variable:
mapping(address => ContractInfo) m_allowed;
A contract owner is supposed to call the setAllowance() external function to specify limits. It also processes getCredit() internal messages and sends the allowed loan amount in response.
RemoteContract ([contract05-b](https://github.com/tonlabs/samples/blob/master/solidity/contract05-b.sol)) is a client that makes a loan request. It can take getMyCredit() external requests, forward those to a specified IMyContract type account and store the answer in a m_answer state variable.

[contract06](https://github.com/tonlabs/samples/blob/master/solidity/contract06-a.sol): balance information

Call "MyContract.method(address anotherContract)". This function calls a remote contract.
The remote [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract06-b.sol) obtains the balance of the inbound message via **msg.value** and its own balance via **address(this).balance** and stores both of them in state variables.

[contract07](https://github.com/tonlabs/samples/blob/master/solidity/contract07-a.sol): send grams and value to a specified contract

Call "MyContract.sendMoneyAndNumber(address anotherContract, uint64 number)". This function send the \<number\> to contract with specified address and attaches fixed amount of grams to the message. 
The remote [contract](https://github.com/tonlabs/samples/blob/master/solidity/contract07-b.sol) recieves value and amount of grams and stores them in state variables.

[contract08](https://github.com/tonlabs/samples/blob/master/solidity/contract08-a.sol): exchange of different types of values

One of contract functions call allows to send to the [remote contract](https://github.com/tonlabs/samples/blob/master/solidity/contract08-b.sol) different values:
- uint64 array;
- two uint64 arrays;
- five uint arrays;
- five uint256;
- struct array.

[contract09](https://github.com/tonlabs/samples/blob/master/solidity/contract09.sol): fallback funciton

Call "Caller.sendMoney(address anotherContract, uint cmd)". This function allows to send grams to different recipients and obtain situations when the fallback function should be called. One of cases uses [CrashContract](https://github.com/tonlabs/samples/blob/master/solidity/contract09-a.sol) which crashes under certain conditions and can cause fallback function call.

[contract10](https://github.com/tonlabs/samples/blob/master/solidity/contract10.sol): customizable constructor

This sample demonstrates how user can write his own contract constructor.

[contract11](https://github.com/tonlabs/samples/blob/master/solidity/contract11-a.sol): selfdestruct function

Call "Kamikaze.sendAllMoney(address anotherContract)". This function deletes the contract and sends all its grams to the specified [remote contract](https://github.com/tonlabs/samples/blob/master/solidity/contract11-b.sol).

[Wallet](https://github.com/tonlabs/samples/blob/master/solidity/Wallet.sol): Simple wallet

Call "Wallet.sendTransaction(address payable dest, uint128 value, bool bounce)". This funciton allows to transfer grams to a specified account.

[PiggyBank](https://github.com/tonlabs/samples/blob/master/solidity/PiggyBank.sol): Piggy bank with two clients

This sample consists of 3 contracts:
- [PiggyBank](https://github.com/tonlabs/samples/blob/master/solidity/PiggyBank.sol) - piggy bank itself.
- [PiggyBank_Owner](https://github.com/tonlabs/samples/blob/master/solidity/PiggyBank_Owner.sol) - piggy bank's owner - valid user, who can add to piggy bank's deposit and withdraw.
- [PiggyBank_Stranger](https://github.com/tonlabs/samples/blob/master/solidity/PiggyBank_Stranger.sol) - stranger - invalid user, who can add to piggy bank but can't withdraw.

Call "PiggyBank_Owner.addToDeposit(PiggyBank bankAddress, uint amount)" or "PiggyBank_Stranger.addToDeposit(PiggyBank bankAddress, uint amount)" to transfer grams from the contract to PiggyBank.

Call "PiggyBank_Owner.withdrawDeposit(PiggyBank bankAddress)" of "PiggyBank_Stranger.withdrawDeposit(PiggyBank bankAddress)" to try to withdraw the deposit from PiggyBank. Transfer would occur only for the owner.

## Contract deployment

Here we describe \<MyContract.sol\> deployment to the TON Blockchain Test Network (testnet) using Lite Client.

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


