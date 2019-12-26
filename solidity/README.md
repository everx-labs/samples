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
starting with very basic and gradually evolving into code snippets, which may come handy in production smart-contracts.

Interaction with the contract in each of the samples described below starts with calling one of its public functions
with parameters. 
In the descriptions below:
"Calling public function \<myFunction\> of the contract \<MyContract\> with an argument name \<parameter\> of type \<type\>."
is expressed as "Call \<MyContract\>.\<myFunction\>(\<type\> \<parameter\>)".

1) [Accumulator](https://github.com/tonlabs/samples/blob/master/solidity/1_Accumulator.sol): persistent storage

Smart-contracts deployed to the blockchain store their state variables in a persistent storage.
Call "Accumulator.add(uint value)". It adds "value" to its state variable "sum".
Resulting state of the account can be examined by conventional means.

2) [StorageClient](https://github.com/tonlabs/samples/blob/master/solidity/2_StorageClient.sol): calling another [contract](https://github.com/tonlabs/samples/blob/master/solidity/2_UintStorage.sol)

Contracts can also call other remote contracts. Call "StorageClient.store(Storage storageAddress) to invoke a public function of another contract.
The remote contract (UintStorage) saves the integer value of the argument and the caller address in its state variables.

3) [Borrower](https://github.com/tonlabs/samples/blob/master/solidity/3_Borrower.sol): gram transfer

This sample demonstrates how currency transfer works. Call "Borrower.askForALoan(Loaner loanerAddress, uint amount)". 
This requests \<amount\> of currency from the contract deployed at the specified address. 
The remote contract ([LoanerContract](https://github.com/tonlabs/samples/blob/master/solidity/3_Loaner.sol)) transfers \<amount\> of currency to the caller via **msg.sender.transfer(amount)**.
Each contract has an internal transaction counter. The counter value increases with each transaction and is stored in the persistent memory.

4) [CurrencyExchange](https://github.com/tonlabs/samples/blob/master/solidity/4_CurrencyExchange.sol): callback implementation

Call "CurrencyExchange.updateExchangeRate(address bankAddress, uint16 code)". This function allows interacting with a remote contract by calling its function: "ICentralBank.GetExchangeRate(uint16 code)".
The remote contract [CentralBank](https://github.com/tonlabs/samples/blob/master/solidity/4_CentralBank.sol) obtains caller's address via **msg.sender** and performs a callback.

5) [Bank](https://github.com/tonlabs/samples/blob/master/solidity/5_Bank.sol): loan interaction between Bank and [BankClient](https://github.com/tonlabs/samples/blob/master/solidity/5_BankClient.sol)

Call "Bank.setAllowance(address bankClientAddress, uint amount)".
Bank stores information about loan allowances and current debts for different contracts. This data is recorded in the following state variable:
mapping(address => CreditInfo) clientDB;
A contract owner is supposed to call the setAllowance() function to specify limits. 

[BankClient](https://github.com/tonlabs/samples/blob/master/solidity/5_BankClient.sol) is a client that can interact with Bank.

Call "BankClient.getMyCredit(IBank bank)".
This function calls the remote contract Bank to receive allowed credit limit via Bank invoking the callback function "setCreditLimit(uint limit)".

Call "BankClient.askForALoan(IBank bank, uint amount).
This function call the remote contract Bank to get an amount of credit. According to the current credit info of the BankClient contract Bank will approve the credit via calling the callback function "receiveLoan(uint n_totalDebt)" or refuse the credit via calling the callback function "refusalCallback(uint availableLimit)". 
**receiveLoan** function also obtains balance of the contract via **address(this).balance** and balance of the inbound message via **msg.value** and saves them in state variables.
**refusalCallback** function saves the argument (available credit limit) in the state variable.

6) [DataBase](https://github.com/tonlabs/samples/blob/master/solidity/6_DataBase.sol): exchange of different types of values

One of contract functions call allows sending to the [DataBaseClient](https://github.com/tonlabs/samples/blob/master/solidity/6_DataBaseClient.sol) different values:
- uint64 array;
- five uint arrays;
- five uint256;
- struct array.

7) [Giver](https://github.com/tonlabs/samples/blob/master/solidity/7_Giver.sol): simple giver contract

This sample shows usage of different types of currency transactions and usage of a fallback function.

Call "Giver.transferToAddress(address payable destination, uint amount)" or "Giver.do_tvm_transfer(address payable remote_addr, uint128 grams_value, bool bounce, uint16 sendrawmsg_flag)" to perform a currency transaction.

Call "Giver.transferToCrashContract(address payable destination, uint amount)" to implement a crash during transaction. That will cause an exception in [CrashContract](https://github.com/tonlabs/samples/blob/master/solidity/7_CrashContract.sol) and Giver's contract fallback function calling.

Call "Giver.transferToAbstractContract(address payable destination, uint amount)" with a non-existent address AbstractContract will also call a fallback function of Giver.

8) [Kamikaze](https://github.com/tonlabs/samples/blob/master/solidity/8_Kamikaze.sol): selfdestruct function

Call "Kamikaze.sendAllMoney(address anotherContract)". This function destroys the contract and sends all its funds to the specified address of [Heir](https://github.com/tonlabs/samples/blob/master/solidity/8_Heir.sol) contract.

9) [PiggyBank](https://github.com/tonlabs/samples/blob/master/solidity/9_PiggyBank.sol): Piggy bank with two clients

This sample consists of 3 contracts:
- [PiggyBank](https://github.com/tonlabs/samples/blob/master/solidity/9_PiggyBank.sol) - piggy bank itself.
- [PiggyBank_Owner](https://github.com/tonlabs/samples/blob/master/solidity/9_PiggyBank_Owner.sol) - piggy bank's owner - valid user, who can add to piggy bank's deposit and withdraw.
- [PiggyBank_Stranger](https://github.com/tonlabs/samples/blob/master/solidity/9_PiggyBank_Stranger.sol) - stranger - invalid user, who can add to piggy bank but can not withdraw.

Call "PiggyBank_Owner.addToDeposit(PiggyBank bankAddress, uint amount)" or "PiggyBank_Stranger.addToDeposit(PiggyBank bankAddress, uint amount)" to transfer grams from the contract to PiggyBank.

Call "PiggyBank_Owner.withdrawDeposit(PiggyBank bankAddress)" of "PiggyBank_Stranger.withdrawDeposit(PiggyBank bankAddress)" to try to withdraw the deposit from PiggyBank. Transfer would occur only for the owner.

10) [Wallet](https://github.com/tonlabs/samples/blob/master/solidity/10_Wallet.sol): Simple wallet

Call "Wallet.sendTransaction(address payable dest, uint128 value, bool bounce)". This function allows transferring grams to the specified account.

11) [ContractDeployer](https://github.com/tonlabs/samples/blob/master/solidity/11_ContractDeployer.sol): Deploy Contract from contract

Call "ContractDeployer.setContract(TvmCell memory _contract)" and then "ContractDeployer.deploy(uint256 pubkey, uint128 gram_amount, uint32 constuctor_id, uint32 constuctor_param0, uint constuctor_param1)" to deploy a contract. It's address will be stored in the state variable "contractAddress".

Call "ContractDeployer.setCode(TvmCell memory _code)" and then "ContractDeployer.deploy2(TvmCell memory data, uint128 gram_amount, uint32 constuctor_id, uint32 constuctor_param0, uint constuctor_param1)" to deploy a contract. It's address will be stored in the state variable "contractAddress".

Call "ContractDeployer.setCode(TvmCell memory _code)" and then "ContractDeployer.deploy2(TvmCell memory data, uint128 gram_amount, uint32 constuctor_id, uint32 constuctor_param0, uint constuctor_param1)" to deploy a contract. It's address will be stored in the state variable "contractAddress".

The way to get arguments for the functions above is described in paragraph **Deploy contract from contract**.

12) [BadContract](https://github.com/tonlabs/samples/blob/master/solidity/12_BadContract.sol): Contract upgrade

Contract code could be changed via using **tvm_setcode** function. It could be useful for fixing errors and functionality updating.
In that example we have a [BadContract](https://github.com/tonlabs/samples/blob/master/solidity/12_BadContract.sol) (it is a [PiggyBank](https://github.com/tonlabs/samples/blob/master/solidity/9_PiggyBank.sol) contract with added upgrade functionality) and new version of that contract [NewVersion](https://github.com/tonlabs/samples/blob/master/solidity/12_NewVersion.sol).

Call "PiggyBank.setCode(TvmCell memory newcode)" with argument that contains code of [NewVersion](https://github.com/tonlabs/samples/blob/master/solidity/12_NewVersion.sol) contract to change the code of the contract.

Call "PiggyBank.after_code_upgrade()" after changing the code of the contract to execute nesessary actions after upgrade.

## Contract deployment

Here we describe \<MyContract.sol\> deployment to the TON Blockchain Test Network (testnet) using Lite Client.

### 1) Compilation
Compile and link the Solidity source file to TVM bytecode as described above:
```
solc --tvm MyContract.sol > MyContract.code
solc --tvm_abi MyContract.sol > MyContract.abi.json
tvm_linker compile MyContract.code -w 0 --lib <path_to>/stdlib_sol.tvm --abi-json MyContract.abi.json [--genkey <path_to_save_keyfile>]
```

Notice that we have added argument "-w 0" to the tvm_linker, where "0" - is the id of workchain (default is -1).
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
The contract is going to store its code and data in the blockchain, but it costs money. So we must transfer some coins to the future contract address before deploying the contract. Some of the ways to get test coins are covered in **Getting test grams**.

### 4) Contract deployment
When we have a constructor message **.boc** file for the contract and we have replenished the balance of the address we are going deploy to, we can run the Lite Client with [configuration file for the TON Blockchain Test Network](https://test.ton.org/ton-lite-client-test1.config.json) and send the file:
```
lite-client -C ton-lite-client-test1.config.json
sendfile <path_to_file_<*-msg-init.boc>>
```

<*-msg-init.boc> is the file we obtained on the **step 2**.
After that, we can check the account again and see that the output now contains the state of the contract:
```
getaccount 0:<MyContractAddress>
```

### 5) Contract function call
To call a function of the contract we should prepare a special message and then send it to the testnet:
```
tvm_linker message <MyContractAddress> -w 0 --abi-json MyContract.abi.json --abi-method '<FunctionName>' --abi-params '{<FunctionArguments>}' [--setkey <path_to_keyfile>]
```

\'\{\<FunctionArguments\>\}\' should have the following form: \'\{"<Argument1_Name>":"Argument1_Value", "<Argument2_Name>":"Argument2_Value", ... \}\'
The command above will create a .boc file which we should send to the testnet as it was described on **step 4**.

## Getting test grams

At present, we can describe two ways to obtain test grams:

### 1) Ask your mate to send test grams to your address.
If you have a mate who works with TON smart contracts he may have some extra test grams and a contract with transfer function (e.g. it could be a Wallet contract, which can send test grams to a given address). In this situation, you can ask him/her to send some test grams to your address.

### 2) Use giver contract.
If you know that there is a giver contract in your TON network and you know its address and possibly keys you can ask giver to transfer some test grams to your address.

2.1) If you need to use keys with your giver save them into 2 files:
  **secret.key** - 64 bytes concatenation of secret key and public key;
  **public.key** - 32 bytes of public key.

2.2) Use tvm_linker to create message that we will call giver's function. Use giver's abi to create this message (in this example giver's abi was saved to file giver.abi.json and function name and arguments were taken from it).

```
tvm_linker message <GiverAddress> -w 0 --abi-json giver.abi.json --abi-method 'sendTransaction' --abi-params '{"dest":"0:<MyContractAddress>","value":"<number of nanograms>","bounce":"false"}' --setkey secret.key
```

\<GiverAddress\> - address of the giver contract in HEX format without workchain id.
The command generates **.boc** file with name \<\*-msg-body.boc\>.

2.3) Use lite_client to send **.boc** file obtained on step **2.2**.
Run lite_client:

```
lite-client -C ton-lite-client-test1.config.json
```

Send out **.boc** file.

```
sendfile <path_to_file_<*-msg-body.boc>>
```
2.4) Check whether the balance replenishment was successful: 
We can perform this check in different ways:

2.4.1) Using gramscan service:

Go to https://gram-scan-test.firebaseapp.com/accounts?section=account-details&id=0:<MyContractAddress\> using your contract address.

2.4.2) Using GraphQL:

Go to testnet.ton.dev/graphql and run that code:

```
{
  accounts
  (filter:{id:{eq:"0:<MyContractAddress>"}})
  {
    acc_type
    balance
    code
  }
}
```

In case of success, you will see the code similar to this:
```
{
  "data": {
    "accounts": [
      {
        "acc_type": 0,
        "balance": "<NumberOfNanograms>",
        "code": null
      }
    ]
  }
}
```

2.4.3) Using lite_client:

Run lite_client and execute the following command:

```
getaccount 0:<MyContractAddress>
```

If everything is OK, you will see an output containing the similar data:

```
...
           value:(currencies
             grams:(nanograms
               amount:(var_uint len:5 value:<NumberOfNanograms>))
...
```

## Deploy contract from contract

User can deploy contract from contract using function tvm_deploy_contract (like in sample [ContractDeployer](https://github.com/tonlabs/samples/blob/master/solidity/11_ContractDeployer.sol)) but it's necessary to generate right arguments.
How to generate arguments for tvm_deploy_contract:

1) Contract's StateInit:
Compile contract:

```
tvm_linker compile <MyContract>.code --lib <path_to_stdlib_sol.tvm> [-w 0] [--abi-json <MyContract>.abi.json] [--genkey <path_to_key_file>]
```

This commang will print the address of the contract and generate file \<MyContractAddress\>.tvc.
Get StateInit using python:

```
with open("<path_to_tvc_file>", "rb") as f:
   stateInitInBase64 = base64.b64encode(f.read()).decode()
```

Obtain StateInit in Solidity using contract's code and data:

```
TvmCell memory contr = tvm_build_state_init(m_code, data);
TvmCell memory contr = tvm_insert_pubkey(m_contract, pubkey); // insert public key if necessary
```

2) Contract's code:
Using tvc file from **step1**:

```
tvm_linker decode --tvc <MyContractAddress>.tvc
```

This command will print contract's code and data.

3) Address of the contract:
Using tvm_linker complie or in Solidity:

```
address addr = tvm_make_address(0, tvm_hashcu(contr));
```

4) ID of constructor function:
Compile contract with tvm_linker and find in linker output log:

```
Function constructor                   : id=1448013A public=true
```

5) Payload:
Generate constructor calling message with tvm_linker:

```
tvm_linker message <MyContractAddress> --data <[constructor_id] + {list_of_constructor_arguments_in_hex}>
```
