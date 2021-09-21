# Deploy contracts from the contract

## Introduction

Convenient way to deploy contracts from the contract is using `new ContractName{value: ..., ...}(arg0, arg1, ...)` construction. Obligatory call options for such construction:
* Either `stateInit` or `code` must be set. Option `stateInit` is an initial state of the contract that contains `code` and `data`. Option `code` contains the code of the contract.
* `value` - funds that will be transferred to the deployed address.

Also [another options](https://github.com/tonlabs/TON-Solidity-Compiler/blob/master/API.md#deploy-via-new) can be set.

It needs a solidity source code (*.sol file) and `stateInit` or `code` in base64 to deploy a contract from the contract. Solidity source code  should be imported into the contract that will deploy new contract. `.code` file should be compiled with [tvm_linker](https://github.com/tonlabs/TVM-linker) to get `stateInit`/`code` in base64 of new contract.

Let's consider how deploy a [SimpleWallet](https://github.com/tonlabs/samples/blob/master/solidity/17_SimpleWallet.sol) contract from the [WalletProducer](https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.sol) contract. In `WalletProducer` contract there are two public functions that deploy contracts:
1. `deployWalletUsingCode` - uses `code` to deploy a contract.
2. `deployWalletUsingStateInit` - uses `stateInit` to deploy a contract.

**Note**: linker creates a `*.tvc` file. This file represents `stateInit`. `stateInit` has such fields as `code`, `data` and etc. In first case we create `stateInit` onchain in smart contract's construction `new SimpleWallet{code: ..., ...}(...)`. In second case we create `stateInit` offchain using tonos-cli to set public key and static variables in the `data` field of the `stateInit`.

## 1. Compiling and deploying the contract deployer (`WalletProducer`)

```bash
# Generate 17_ContractProducer.code and 17_ContractProducer.abi.json
solc 17_ContractProducer.sol

# Generate <TVC_PRODUCER_HASH>.tvc
tvm_linker compile 17_ContractProducer.code --lib stdlib_sol.tvm \
    --abi-json 17_ContractProducer.abi.json

# Set public key for ContractProducer contract
tonos-cli genaddr --save --setkey key0.key <TVC_PRODUCER_HASH>.tvc 17_ContractProducer.abi.json
```

Last command updates the <TVC_PRODUCER_HASH>.tvc file and prints the address of the contract (it's just hash of that file). Let's denote address of thr WalletProducer as `<PRODUCER_ADDRESS>`. Then send funds on `<PRODUCER_ADDRESS>` address from your wallet or giver and deploy the `ContractProducer` contract:

```bash
tonos-cli deploy --sign key0.key --abi 17_ContractProducer.abi.json <TVC_PRODUCER_HASH>.tvc
```

### 2. Compiling and linking `SimpleWallet` contract

```bash
solc 17_SimpleWallet.sol

tvm_linker compile 17_SimpleWallet.code --lib stdlib_sol.tvm \
    --abi-json 17_SimpleWallet.abi.json
```

Last command generates the `<TVC_WALLET_HASH>.tvc` file.

#### 3.1 Using `code` to deploy a contract from the contract

Get `code` from `<TVC_WALLET_HASH>.tvc` file:

```bash
tvm_linker decode --tvc <TVC_WALLET_HASH>.tvc
```

Copy `code` section from the linker output. Let's denote this code as `<CODE_IN_BASE64>`.

Call function `deployWalletUsingCode` to deploy a new `SimpleWallet` contract:

```bash
tonos-cli call --sign key0.key --abi 17_ContractProducer.abi.json \
    <PRODUCER_ADDRESS> deployWalletUsingCode \
    '{"walletCode":"<CODE_IN_BASE64>","publicKey0":"<SOME_VALUE_0>","publicKey1":"<SOME_VALUE_1>"}'
```

This call returns address of the new `SimpleWallet` contract. Then the new contract is successfully deployed, that can be checked by obtaining it's account state with `tonos-cli`.

#### 3.2 Using `stateInit` to deploy a contract from the contract

Let's set a public key and static variables in the `data` field of the `stateInit` struct.

```bash
tonos-cli genaddr --setkey key1.key <TVC_WALLET_HASH>.tvc \
    17_SimpleWallet.abi.json \
    --save --data '{"m_id":"444", "m_creator":"<PRODUCER_ADDRESS>"}'
```

`*.tvc` file represents `stateInit`. Get `stateInit` in base64:

```bash
base64 -w 0 <TVC_WALLET_HASH>.tvc
```

Let's denote output of the last command as `<STATEINIT_IN_BASE64>`.
Call function `deployWalletUsingStateInit` to deploy a new `SimpleWallet` contract:

```bash
tonos-cli call --sign key0.key --abi 17_ContractProducer.abi.json \
    <PRODUCER_ADDRESS> deployWalletUsingStateInit \
    '{"stateInit":"<STATEINIT_IN_BASE64>","publicKey1":"<SOME_VALUE_1>"}'
```

This call returns address of the new `SimpleWallet` contract.  Then the new contract is successfully deployed, that can be checked by obtaining it's account state with `tonos-cli`.

###  See also:

 * [Low level constructor message structure](https://github.com/tonlabs/samples/blob/master/solidity/17_low_level.md)
