# Deploy contract from contract

Convenient way to deploy contract from contract is to do it using "new Contract" construction.  
Example from [WalletProducer](https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.sol):

```TVMSolidity
address newWallet = new SimpleWallet{stateInit: stateInitWithKey, value: initialValue}();
```

Obligatory call options for such construction are:

* Either `stateInit` or `code`. Option `stateInit` - is an initial state
of the contract that contains `code` and `data`. Option `code` contains the
code of the contract.
* "value" - funds that will be transferred to the deployed address.

Also developer can set [another options](https://github.com/tonlabs/TON-Solidity-Compiler/blob/master/API.md).

## How to get arguments for contract deployment

To deploy a contract from contract developer needs target contracts source code (*.sol file) and `stateInit`/`code` in base64. Source code is a solidity file which should be imported into the contract deployer's source file. To get `stateInit`/`code` in base64 `.code` file should be compiled with [tvm_linker](https://github.com/tonlabs/TVM-linker).

Let consider how to get arguments and call [WalletProducer](https://github.com/tonlabs/samples/blob/master/solidity/17_ContractProducer.sol) constructor:

### 1. Compile wallet contract and obtain its code

Generate `17_SimpleWallet.code` and `17_SimpleWallet.abi.json` files:

```bash
solc 17_SimpleWallet.sol
```

Generate the `*.tvc` file:

```bash
tvm_linker compile 17_SimpleWallet.code --abi-json 17_SimpleWallet.abi.json --lib $PATH_TO_STDLIB_SOL
```

Possible output of the last command:

```bash
 ...
Saved contract to file 492c891deff0abd952c9db5aaf3255175425edb51da664d6dcb3834548f1d155.tvc
 ...
```

`*.tvc` file contains `stateInit` of the contract. Get `stateInit` in
base64 if it's needed:

```bash
base64 -w 0 492c891deff0abd952c9db5aaf3255175425edb51da664d6dcb3834548f1d155.tvc
```

Let's denote this `stateInit` as <STATEINIT_IN_BASE64>.

Get `code` from `stateInit` if it's needed:

```bash
tvm_linker decode --tvc 492c891deff0abd952c9db5aaf3255175425edb51da664d6dcb3834548f1d155.tvc
```

Copy `code`section. Let's denote this code as <CODE_IN_BASE64>.

### 2. Compile contract deployer

```bash
solc 17_ContractProducer.sol
tvm_linker compile 17_ContractProducer.code --abi-json 17_ContractProducer.abi.json --lib PATH_TO_STDLIB_SOL
```

The last command generates the tvc file:

```bash
...
Saved contract to file 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189.tvc
...
```

### 3. Simulate call of deployer constructor locally using tvm_linker

```bash
tvm_linker test 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189 --abi-json 17_ContractProducer.abi.json --abi-method constructor --abi-params '{"walletCode": "<CODE_IN_BASE64>"}'
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

Generated keys are saved to file Wallet.key. In examples below public key from that file is denoted by \<PUBKEY\>.

### 5. Simulate call of wallet deployment function

Get public key from the file generated on the previous step.

```bash
tvm_linker test 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189 --abi-json 17_ContractProducer.abi.json --abi-method deployWallet --abi-params '{"publicKey": "0x<PUBKEY>"}'
```

tvm_linker can show and decode the output message by using "--decode-c6" option:

```bash
tvm_linker test 02163393a1a8fdbad68b9652b245340cc0d13d7ef36c5bcc0e9d51ccbf1ad189 --abi-json 17_ContractProducer.abi.json --abi-method deployWallet --abi-params '{"publicKey": "0x<PUBKEY>"}' --decode-c6
```

## Constructor message structure

All messages in TON have type **Message X**. Spec describes this type in TL-B scheme:

```TL-B
message$_ {X:Type} info:CommonMsgInfo
init:(Maybe (Either StateInit ^StateInit))
body:(Either X ^X) = Message X;
```

CommonMsgInfo structure has 3 types:

* Internal message info;
* External inbound message info;
* External outbound message info.

To deploy a new contract we need to send an internal message. TL-B scheme for CommonMsgInfo of internal message:

```TL-B
int_msg_info$0 ihr_disabled:Bool bounce:Bool src:MsgAddressInt dest:MsgAddressInt
value:CurrencyCollection ihr_fee:Grams fwd_fee:Grams created_lt:uint64
created_at:uint32 = CommonMsgInfo;
```

CommonMsgInfo contains structures, that are described by the following TL-B schemes:

```TL-B
nothing$0 {X:Type} = Maybe X;
just$1 {X:Type} value:X = Maybe X;
left$0 {X:Type} {Y:Type} value:X = Either X Y;
right$1 {X:Type} {Y:Type} value:Y = Either X Y;

anycast_info$_ depth:(## 5) rewrite_pfx:(depth * Bit) = Anycast;

addr_none$00 = MsgAddressExt;

addr_std$10 anycast:(Maybe Anycast)
workchain_id:int8 address:uint256 = MsgAddressInt;

var_uint$_ {n:#} len:(#< n) value:(uint (len * 8))
= VarUInteger n;
nanograms$_ amount:(VarUInteger 16) = Grams;

extra_currencies$_ dict:(HashmapE 32 (VarUInteger 32))
= ExtraCurrencyCollection;
currencies$_ grams:Grams other:ExtraCurrencyCollection
= CurrencyCollection;
```

When we deploy a contract we need to attach stateInit of that contract, but we [use tvm_linker to obtain it](#1-compile-wallet-contract-and-obtain-its-code), that's why we don't need to construct it.

In case of deployment via **new** we also pass arguments to the constructor of the contract. That's why we need to attach constructor call as the body of the message. To do it we need to store **constructor** function identifier and encode it's parameters.

In binary form the whole constructor message look like this:

```TVM_Message
---CommonMsgInfo---
0                   - int_msg_info$0 - constant value
1                   - ihr_disabled - true (currently disabled for TON)
1                   - bounce - true (we want this message to bounce to the sender in case of error)
0                   - bounced - false (this message is not bounced)

00                  - src:MsgAddress we store addr_none$00 because blockchain software will replace
                      it with the current smart-contract address

                    - dest:MsgAddressInt:
10                  - addr_std$10 - constant value
00000000            - workchain_id:int8 - store zero
hash(stateInit)     - address:uint256 - address of the contract is equal to hash of the stateInit

                    - value:CurrencyCollection: (for example we will store 10_000_000 nanograms)
                    - grams:Grams
0011                - len (because 10_000_000 < 2^(3*8))
x989680             - value (3*8 bits)
0                   - other:ExtraCurrencyCollection  (we don't attach any other currencies)

                    - In the next 4 fields we store zeroes, because blockchain software will replace them
                      with the correct values after this function finishes execution.
0000                - ihr_fee:Grams
0000                - fwd_fee:Grams
x0000000000000000   - created_lt:uint64
x00000000           - created_at:uint32
------------------

---stateInit---
1                   - Maybe - 1 because we attach a stateInit
1                   - Either StateInit ^StateInit - 1 because we store stateInit in a ref
                    - Store stateInit in a ref of
---------------

---body---
0/1                 - Maybe: 0 if store body in current cell, otherwise 1
constructorID       - uint32 constructor identifier value
<encoded constructor params>
----------
```
