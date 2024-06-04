# Deploy contracts from the contract

## Introduction

Convenient way to deploy contracts from the contract is using `new ContractName{value: ..., ...}(arg0, arg1, ...)` construction. Obligatory call options for such construction:
* Either `stateInit` or `code` must be set. Option `stateInit` is an initial state of the contract that contains `code` and `data`. Option `code` contains the code of the contract.
* `value` - funds that will be transferred to the deployed address.

Also, [another options](https://github.com/everx-labs/TVM-Solidity-Compiler/blob/master/API.md#deploy-via-new) can be set.

It needs a solidity source code (*.sol file) and `stateInit` or `code` in base64 to deploy a contract from the contract. Solidity source code  should be imported into the contract that will deploy new contract. `.code` file should be compiled with [tvm_linker](https://github.com/everx-labs/TVM-linker) to get `stateInit`/`code` in base64 of new contract.

Let's consider how deploy a [SimpleWallet](https://github.com/everx-labs/samples/blob/master/solidity/17_SimpleWallet.sol) contract from the [WalletProducer](https://github.com/everx-labs/samples/blob/master/solidity/17_ContractProducer.sol) contract. In `WalletProducer` contract there are two public functions that deploy contracts:
1. `deployWalletUsingCode` - uses `code` to deploy a contract.
2. `deployWalletUsingStateInit` - uses `stateInit` to deploy a contract.

**Note**: linker creates a `*.tvc` file. This file represents `stateInit`. `stateInit` has such fields as `code`, `data` etc. In first case we create `stateInit` onchain in smart contract's construction `new SimpleWallet{code: ..., ...}(...)`. In second case we create `stateInit` offchain using ever-cli to set public key and static variables in the `data` field of the `stateInit`.

## 1. Compiling and deploying the contract deployer (`WalletProducer`)

```bash
# Generate 17_ContractProducer.code and 17_ContractProducer.abi.json
solc 17_ContractProducer.sol

# Generate the tvc file
tvm_linker compile 17_ContractProducer.code --lib stdlib_sol.tvm -o 17_ContractProducer.tvc

# Generate the keypair, set public key for ContractProducer contract and obtain contract address
ever-cli genaddr --save --genkey key0.key 17_ContractProducer.tvc 17_ContractProducer.abi.json
```

**Note**: `--genkey` option can be changed to `--setkey` if you have a file with a keypair and want to use it.
Last command updates the 17_ContractProducer.tvc file and prints the address of the contract (it's just hash of the updated file). Let's denote address of the WalletProducer as `<PRODUCER_ADDRESS>`. Then send funds on `<PRODUCER_ADDRESS>` address from your wallet or giver and deploy the `WalletProducer` contract:

```bash
ever-cli deploy --sign key.key --abi 17_ContractProducer.abi.json 17_ContractProducer.tvc '{}'
```

## 2. Compiling and linking `SimpleWallet` contract

```bash
solc 17_SimpleWallet.sol

tvm_linker compile 17_SimpleWallet.code --lib stdlib_sol.tvm -o 17_SimpleWallet.tvc
```

Last command generates the `17_SimpleWallet.tvc` file.

## 3. Deploying the `SimpleWallet`

### 3.1 Using `code` to deploy a contract from the contract

Get `code` from `17_SimpleWallet.tvc` file:

```bash
tvm_linker decode --tvc 17_SimpleWallet.tvc
```

Copy the `code` section from the linker output. Let's denote it as `<CODE_IN_BASE64>`.

Generate 2 public keys required to deploy a `SimpleWallet` contract:

```bash
# Generate a seed phrase (it is used in other commands and denoted as <SEED_PHRASE> 
ever-cli genphrase

# Genrate a keypair from the seed phrase and save it to the file
ever-cli getkeypair key1.key "<SEED_PHRASE>"

ever-cli genphrase
ever-cli getkeypair key2.key "<SEED_PHRASE2>"
```

After this commands the keypair file can be opened and a public key can be copied from it to use later.
Let's denote this 2 public keys as `<PUBKEY_0>` and `<PUBKEY_1>`.  
Example of the file with a keypair:

```json
{
  "public": "03a4d60fc3d67eebb3a0267f172439f6ae0cfcfab4a0a44c0fe8a3c92b97d3dc",
  "secret": "7539d54d6ece6f727dc64268dd2e3975765b230e7d56ea5afa2b39eb62ff9d9d"
}
```

Call function `deployWalletUsingCode` to deploy a new `SimpleWallet` contract:

```bash
ever-cli call --sign key0.key --abi 17_ContractProducer.abi.json \
    <PRODUCER_ADDRESS> deployWalletUsingCode \
    '{"walletCode":"<CODE_IN_BASE64>","publicKey0":"0x<PUBKEY_0>","publicKey1":"0x<PUBKEY_1>"}'
```

This call returns address of the new `SimpleWallet` contract (It's denoted as `<WALLET_ADDRESS>`). Then the new contract is successfully deployed, that can be checked by obtaining it's account state with `ever-cli`:

```bash
ever-cli account <WALLET_ADDRESS>
```

Example of the last command output:

```
acc_type:      Active
balance:       981590000 nanoton
last_paid:     1632420089
last_trans_lt: 0x17
data(boc):     b5ee9c720101020100b00001d103a4d60fc3d67eebb3a0267f172439f6ae0cfcfab4a0a44c0fe8a3c92b97d3dc0000000000000000800000000000000000000000000000000000000000000000000000000000001681d26b07e1eb3f75d9d0133f8b921cfb57067e7d5a50522607f451e495cbe9ee4001008300000000000000000000000000000000000000000000000000000000000000008009249c823901fed37b652b1eca5aeaef2aec694675317807a891fc3e90bf005c70
code_hash:     b4ac0a0f61ffddc1db5cec6c66abade1064b12dc528795699bc7cd0791b7868e
```

`SimpleWallet` can be called now using its abi:

```bash
ever-cli call --abi 17_SimpleWallet.abi.json --sign key1.key <WALLET_ADDRESS> sendTransaction '{"destination":"<WALLET_ADDRESS>","value":"100_000_000","bounce":"false","flag":1}'
ever-cli call --abi 17_SimpleWallet.abi.json --sign key2.key <WALLET_ADDRESS> sendTransaction '{"destination":"<WALLET_ADDRESS>","value":"100_000_000","bounce":"false","flag":1}'
```

### 3.2 Using `stateInit` to deploy a contract from the contract

Let's set a public key and static variables in the `data` field of the `SimpleWallet` contract `stateInit` struct.

```bash
ever-cli genaddr --setkey key1.key 17_SimpleWallet.tvc 17_SimpleWallet.abi.json --save --data '{"m_id":"444", "m_creator":"<PRODUCER_ADDRESS>"}'
```

`*.tvc` file represents contract's `stateInit`. Get `stateInit` in base64:

```bash
base64 -w 0 17_SimpleWallet.tvc
```

Let's denote output of the last command as `<STATEINIT_IN_BASE64>`.
Call function `deployWalletUsingStateInit` to deploy a new `SimpleWallet` contract:

```bash
ever-cli call --sign key0.key --abi 17_ContractProducer.abi.json <PRODUCER_ADDRESS> deployWalletUsingStateInit '{"stateInit":"<STATEINIT_IN_BASE64>","publicKey1":"0x<PUBKEY_1>"}'
```

This call returns address of the new `SimpleWallet` contract.  Then the new contract is successfully deployed, that can be checked as in previous section.

#  See also:

 * [Low level constructor message structure](https://github.com/everx-labs/samples/blob/master/solidity/17_low_level.md)
