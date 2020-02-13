# Piggybank

## Methods
This contract has three methods.
* `Piggybank::constructor(MsgAddress owner, uint256_t limit)` - initialization of contract.
* `Piggybank::deposit()` - receive transfer and increase internal balance.
* `Piggybank::withdraw()` - check that sender is owner, balance is greater than limit and transfer all balance to owner.

## Persistent data
* MsgAddress `owner` - contract's owner, initialized in `Piggybank::constructor()` call.
* uint256_t `limit` - limit to allow withdrawal.
* uint256_t `balance` - current balance.

## Compilation (manual, step-by-step, without tvm-build++)

Generate json-abi file:
```
clang -target tvm --sysroot TON-Compiler/stdlib/ Piggybank.cpp -export-json-abi -o Piggybank.abi
```
Compile into llvm ir file:
```
clang -target tvm -O3 --sysroot TON-Compiler/stdlib/ -c -S -emit-llvm Piggybank.cpp -o Piggybank.ll
```
Optimize llvm ir file #1:
```
opt Piggybank.ll -S -o Piggybank.opt1.ll -internalize -internalize-public-api-list=main_external,main_internal,main_ticktock,main_split,main_merge
```
Optimize llvm ir file #2:
```
opt -S -O3 Piggybank.opt1.ll -o Piggybank.opt2.ll
```
Assembly generation:
```
llc Piggybank.opt2.ll -O3 -o Piggybank.s
```
Linking of contract:
```
tvm_linker compile Piggybank.s --lib TON-Compiler/stdlib/stdlib_cpp.tvm --abi-json Piggybank.abi --genkey/setkey...
```
Variant with genkey:
```
tvm_linker compile Piggybank.s --lib TON-Compiler/stdlib/stdlib_cpp.tvm --abi-json Piggybank.abi --genkey Piggybank.key
```
Read "Key Generation and Usage" document about genkey/setkey details.

Linking will produce file like `7a1c13d5bdf356c03ab4473714819095505df070ff3d61eab1ad5151319abf23.tvc`
```
Saved contract to file 7a1c13d5bdf356c03ab4473714819095505df070ff3d61eab1ad5151319abf23.tvc
```

## Test simulation
Constructor call trace:
```
tvm_linker test --trace --decode-c6 -a Piggybank.abi -m constructor --abi-params='{"owner":"0:e6804f18c4147e9545c23dc4f9663650bead7aae26961558ef8d67e170f834ab", "limit":"10000"}' --sign Piggybank.key 7a1c13d5bdf356c03ab4473714819095505df070ff3d61eab1ad5151319abf23 > constructor.log
```
Deposit call trace:
```
tvm_linker test --trace --decode-c6 -a Piggybank.abi -m deposit --abi-params='{}' --sign Piggybank.key --internal 100000 7a1c13d5bdf356c03ab4473714819095505df070ff3d61eab1ad5151319abf23 > deposit.log
```
Withdraw call trace:
```
tvm_linker test --trace --decode-c6 -a Piggybank.abi -m withdraw --abi-params='{}' --sign Piggybank.key --internal 10 7a1c13d5bdf356c03ab4473714819095505df070ff3d61eab1ad5151319abf23 > withdraw.log
```

