# Deploy contract from contract

Convenient way to deploy contract from contract is to do it using "new Contract" construction.  
Example from [WalletProducer](https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.sol):

```TVMSolidity
address newWallet = new SimpleWallet{stateInit:stateInitWithKey, value:initialValue}();
```

Obligatory call options for such construction are:

* "stateInit" - stateInit of the deployed contract. stateInit is an initial state of the contract that contains code and data;
* "value" - currency value that will be transferred to the deployed address.

Also developer can set option "flag" to specify flag of the constructor message.

## How to get arguments for contract deployment

To deploy contract from contract developer needs another contracts source code and stateInit. Source code is a solidity file which should be imported into the source file of contract deployer. To get stateInit of the contract developer should compile it with [tvm_linker](https://github.com/tonlabs/TVM-linker).
Example of how to get arguments and call [WalletProducer](https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.sol) constructor:

### 1. Compile wallet contract and obtain its stateInit

```bash
solc 17_SimpleWallet.sol
tvm_linker compile 17_SimpleWallet.code -a 17_SimpleWallet.abi.json --lib PATH_TO_STDLIB_SOL
```

The last command generates the tvc file:

```bash
# ...
# Saved contract to file 492c891deff0abd952c9db5aaf3255175425edb51da664d6dcb3834548f1d155.tvc
# ...
```

This file contains stateInit of the contract. To use it as function argument developer should encode data of the file in base64.

```bash
base64 -w 0 492c891deff0abd952c9db5aaf3255175425edb51da664d6dcb3834548f1d155.tvc
```

This command outputs file data in base64. In commands below it's replaced to <BASE64_OF_STATEINIT>.

### 2. Compile contract deployer

```bash
solc 17_ContractProducer.sol
tvm_linker compile 17_ContractProducer.code -a 17_ContractProducer.abi.json --lib PATH_TO_STDLIB_SOL
```

The last command generates the tvc file:

```bash
# ...
# Saved contract to file 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189.tvc
# ...
```

### 3. Simulate call of deployer constructor locally using tvm_linker

```bash
tvm_linker test 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189 --abi-json 17_ContractProducer.abi.json --abi-method constructor --abi-params '{"_walletStateInit": "<BASE64_OF_STATEINIT>", "_initialValue": 100000000}'
```

### 4. Generate a key pair for new wallet

To generate a key pair we will use [tonos-cli](https://github.com/tonlabs/tonos-cli).
At first we need to generate a seed phrase:

```bash
tonos-cli genphrase
```

This command outputs the phrase, which we will be replaced to <SEED_PHRASE> in commands below:

```bash
Succeeded.
Seed phrase: "<SEED_PHRASE>"
```

Generate key pair and save it in file 'Wallet.key':

```bash
tonos-cli getkeypair Wallet.key '<SEED_PHRASE>'
```

### 5. Simulate call of wallet deployment function

Get public key from the file generated on the previous step.

```bash
tvm_linker test 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189 --abi-json 17_ContractProducer.abi.json --abi-method deployWalletWithPubkey --abi-params '{"pubkey": "0x<PUBKEY>"}'
```

tvm_linker can show and decode the output message by using "--decode-c6" option:

```bash
tvm_linker test 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189 --abi-json 17_ContractProducer.abi.json --abi-method deployWalletWithPubkey --abi-params '{"pubkey": "0x<PUBKEY>"}' --decode-c6
```
