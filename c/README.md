# C contract samples for TON
This directory contains contracts that demonstrate how to use C to write contracts for TON blockchain. There is a separate subfolder for each file and its description.

## Prerequisites
TVM Toolchain for C to build and test contracts locally. It includes:
* Clang for TVM available in Node SE and at [https://github.com/tonlabs/TON-Compiler](https://github.com/tonlabs/TON-Compiler)
  * C runtime library distributed with Clang [https://github.com/tonlabs/TON-Compiler/blob/master/stdlib/stdlib_c.tvm](https://github.com/tonlabs/TON-Compiler/blob/master/stdlib/stdlib_c.tvm)
  * TON SDK for C distributed with Clang [https://github.com/tonlabs/TON-Compiler/blob/master/stdlib/abi_parser.py](https://github.com/tonlabs/TON-Compiler/blob/master/stdlib/abi_parser.py)
  * ABI parser tool distributed with Clang [](`stdlib/abi_parser`)
* Assembler & linker tool, tvm_linker; currently available as a binary in Node SE.

To deploy contracts in testnet, you also need Lite Client tool available at [http://test.ton.org](http://test.ton.org)

## Example of usage

Check our [youtube tutorial](https://www.youtube.com/watch?v=Srfor1s1eLM).

We use example-4-piggybank to show the building process.
It is assumed that tools are located in the 'PATH'.
1. Generate wrappers and headers from contracts' ABI.
```
cd example-4-piggybank
abi_parser.py piggybank
```

2. Compile the contract sources.
```
clang -target tvm -S -O3 *.c -I/path/to/stdlib
```

If Clang fails to recognize the TVM target, make sure that you are using Clang for TVM, not the system Clang.

3. Compile the SDK sources.
```
clang -target tvm -S -O3 /path/to/ton-std/*.c -I/path/to/stdlib
```

4. Merge the assemblies together ('tvm_linker' does not support multiple inputs now).
```
cat *.s > piggybank.combined.s
```

5. Assemble and link the contract.
```
tvm_linker compile piggybank.combined.s --abi-json piggybank.abi --lib /path/to/stdlib_c.tvm
```

The linker produces a .tvc file. Its name corresponds to the contract address.
Test the contract locally.
You can invoke a public function specified in the ABI and see the output using 'tvm_linker' tool:
```
tvm_linker test <contract address> --abi-json piggybank.abi --abi-method initialize_target --abi-params "{\"target\":\"100\"}"
```

To learn more about ABI, refer to [https://docs.ton.dev/86757ecb2/p/15062d](https://docs.ton.dev/86757ecb2/p/15062d)

## Contract deployment
Contract deploy guidelines do not depend on the language. You can use the one at [https://github.com/tonlabs/samples/tree/master/solidity](https://github.com/tonlabs/samples/tree/master/solidity).

## C language limitations and performance issues
* Each contract has a limited gas supply; once it is exceeded, a contract terminates with an error.
* TVM does not use float point arithmetic, so float point operations result in an error.
* Contrary to the C specification, unsigned integer overflow can be expected causing an exception.
* TVM has a stack, but no memory. Currently it is emulated via dictionaries in the runtime. Accessing dictionaries consumes a lot of gas, so we strongly discourage the use of globals and getting variable addresses.
* TVM uses 257-bits wide SMR numbers representation. All numeric types are 257-bit wide, and 1 byte = 257 bit. So we suggest making no assumptions about behavior of implementation-defined features of C and C++.

## Unsupported features
* C and C++ standard libraries (partial support is planned)
* Exception handling
* Pointers to functions and virtual methods
* Free store memory allocation / deallocation

## Getting support
Texts, videos and samples illustrating how to use the compiler will soon appear at [https://ton.dev/](https://ton.dev/) and [Youtube channel](https://www.youtube.com/channel/UC9kJ6DKaxSxk6T3lEGdq-Gg). Stay tuned.
You can also get support in [TON Dev Telegram channel](https://t.me/tondev_en).
In case you found a bug, raise an issue in the repository. Please attach the source file, the command to reproduce the failure and your machine description.
