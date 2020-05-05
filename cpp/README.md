## Prerequisites

To compile a contract, you first need to get the following libraries and tools.
- [C++ for TVM compiler, C++ runtime, C++ SDK libraries, C++ driver](https://github.com/tonlabs/TON-Compiler). All libraries and tools are in the same repository.
- [TVM linker and TVM deploying tool](https://github.com/tonlabs/TVM-linker/).

## Contract in C++

A contract in C++ might be written using any C++ standard supported by Clang-7. So a developer could use most of the features available in the most recent C++17 standard. Hovewer since blochain is the domain, C++ was not initially intended for a contract has some limitations:
- All the arithmetic is 257-bits wide, sizeof(char) == sizeof(<any other numeric type>) == 1 byte == 257 bits.
- TVM doesn't support float point arithmetic, so compilation of a contract utilizing float or double type might end up with an internal compiler error.
- TVM has very poor performance when emulating pointers to functions, so a program which _after optimization_ still has calls by a pointer will not compile. So we strongly recommend to use coding style which could be characterized as C with classes and templates with several exceptions that are shown in the examples from this repository.
- Exception handling is not currently supported.

Aside from that, we introduced some extensions into the language to deal with the blockchain specifics:

### Language extensions

- GNU attributes to mark public methods of a contract (see any example from this repo for detais).
- `auto [=a] = expression;`. Structure binding extension allowing to assign to already declared variable a. Note that any mix of new and existing variables is allowed in a structure binding (e.g. `auto [=a, b, c, =d] = expression;` defines `b` and `c` and assigns to `a` and `d`).
- `smart_interface<T>` template class and macro to generate contract ABI (see any example from this repo for detais).
- `void foo() = n` in a pure virtual function declaration is used to designate the public method id in a contract.

Note that C++ compiler is under active development and we aim to improve diagnostic, but at the moment compilation might end up with an internal compiler error. In such case please refer to the aforementined guidelines and ask for help in the community chats.

## C++ compilation workflow

To compile a contract in C++ perform the following steps.
1. Extract the contract ABI (alternatively it could be written by hands, but it duplicates information about the contract interface which is bug prone). To extract the ABI, run
```
clang++ -target tvm --sysroot <path/to/TON-Compiler/stdlib/> Contract.cpp -export-json-abi -o Contract.abi
```

2. Compile the contract and link it
```
export TVM_LINKER=</path/to/tvm_linker/binary>
export TVM_INCLUDE_PATH=</path/to/TON-Compiler/stdlib>
export TVM_LIBRARY_PATH=</path/to/TON-Compiler/stdlib>
</path/to/TON-Compiler/llvm/tools/tvm-build/tvm-build++.py> --abi Contract.abi Contract.cpp --include $TVM_INCLUDE_PATH
```

If the compilation is successful, `*.tvc` file is created in the directory where `tvm-build++` was run.

## Contract deployment

Here we describe a contract deployment to the TON Blockchain Test Network (testnet) using `tonlabs-cli` tool. The following commands must be run from the directory where tonlabs-cli is located.

1. Generate contract address
```
cargo run genaddr Contract.tvc Contract.abi --genkey key
```

The command generates and print lists all possible addresses of the contract:
```
Raw address: <RawAddress>
testnet:
Non-bounceable address (for init): <MyContractNonBounceTestAddress>
Bounceable address (for later access): <MyContractBounceTestAddress>
mainnet:
Non-bounceable address (for init): <MyContractNonBounceMainAddress>
Bounceable address (for later access): <MyContractBounceMainAddress>
```

Later we will use `<RawAddress>` of the contract. Note that `--genkey` (or `--setkey`) is mandatory, it generates a key file which is used for every interaction with the contract made by an offchain application. TVM supports unauthorized external (i.e. from outside of the blockchain) method calls, but C++ currently doesn't.

2. Prepare the account
The contract is going to store its code and data in the blockchain, but it costs money. So we must transfer some coins to the future contract address before deploying the contract. Some of the ways to get test coins are covered in **Getting test grams**.

3. Deploy the contract
```
cargo run deploy --abi Contract.abi Contract.tvc '{<constructor call arguments>}' --sign key
```
Note that call arguments are supposed to be pairs of `"parameter":value` in JSON format. For instance, `'{"a":5, "b":6}'`calls the constructor with a = 5 and b = 6. Note that the parameter names must match ones specified in the contract ABI.

4. Run a method
Method's running is syntactically similar to deploying, but the name of the method should also be specified.
```
cargo run call --abi Contract.abi <RawAddress> '{<call arguments>}' --sign key
```
Note that a contract method might also be called internally (i.e. by another contract), see [Giver](https://github.com/tonlabs/samples/blob/master/cpp/Giver) example to learn more.

## Getting test Grams

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

\<GiverAddress\> - giver contract address in HEX format without workchain id.
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

In case of success, you get the similar code:
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

If everything is OK, you get the following output:

```
...
           value:(currencies
             grams:(nanograms
               amount:(var_uint len:5 value:<NumberOfNanograms>))
...
```

## Contract examples

The list of C++ examples is provided below. If you just started learning C++ for TVM we recommend to start with the [Tutorial](https://github.com/tonlabs/samples/blob/master/cpp/TUTORIAL.md) and then to study the examples in order. If you are familiar with TVM and smart contracts, however, jump to the contract you are interested in.

1) [Hello, world!](https://github.com/tonlabs/samples/blob/master/cpp/HelloWorld): Introduces general concepts of the contract development.

This example is a part of [C++ Tutorial](https://github.com/tonlabs/samples/blob/master/cpp/TUTORIAL.md) which is a step by step guidance on how to create your first contract.

2) [Authorization](https://github.com/tonlabs/samples/blob/master/cpp/Authorization): Demonstrate a message signature check.

This example is a part of [C++ Tutorial](https://github.com/tonlabs/samples/blob/master/cpp/TUTORIAL.md). The example extends [Hello, world!](https://github.com/tonlabs/samples/blob/master/cpp/HelloWorld) example by introducing signature cheching to prevent spam attack on a contract and make it run out of money.

3) [Giver](https://github.com/tonlabs/samples/blob/master/cpp/Giver): The contract sends the requested amount of money.

This example is a part of [C++ Tutorial](https://github.com/tonlabs/samples/blob/master/cpp/TUTORIAL.md). It shows how to call a public method with parameters from another contract.

4) [Wallet](https://github.com/tonlabs/samples/blob/master/cpp/Wallet): Simple contract to hold and spend money.

5) [Piggybank](https://github.com/tonlabs/samples/blob/master/cpp/Piggybank): Contract for savings.

The example consist of three contracts which exchange messages between each other. It shows simplest form of an internal call of a public method. It also show how a mechanism of internal authorization might work.

6) [Kamikaze](https://github.com/tonlabs/samples/blob/master/cpp/Kamikaze): The example shows how a contract could be deleted from the network.
