Note: this tutorial is a work in progress. It updates once C++ for TVM gets a juicy new feature, so we recommend to return to it from time to time.

## Prerequisites
To reproduce the tutorial, you need to get [TON-Compiler sources](https://github.com/everx-labs/TON-Compiler), [TONOS-CLI](https://github.com/everx-labs/tonos-cli), [TVM-linker sources](https://github.com/everx-labs/TVM-linker) and build `clang++`, `tvm_linker` and `tonos-cli`. Please follow `README` files from the corresponding repositories.

## The toolchain description
C++ toolchain consists of the following libraries and tools:
* C++ runtime located at `TON-Compiler-source/stdlib/stdlib_cpp.tvm`.
* C++ std headers at `TON-Compiler-source/stdlib/cpp-sdk/std`. These are mostly original headers from LLVM libstdc++ configured with TVM architecture parameters. You might expect these headers to work and to use them. But we don't guarantee that every single feature will work smoothly: some C++ features are beyound the capabilities of TVM architecture. We address this subject later on in this tutorial.
* Boost hana library which might be used in contracts. It's located at `TON-Compiler-source/stdlib/cpp-sdk/boost`.
*	TON SDK header-based library containing essential functions and classes to work with contracts. It's located at `TON-Compiler-source/stdlib/cpp-sdk/tvm`.
*	Clang-7 based C++ compiler. The binary is located at `TON-Compiler-build/bin/clang++`.
*	`tvm_linker` linker for TVM assembly and also a local testing tool for contracts. The tool is located at `TVM-linker-source/tvm_linker/target/<debug or release>/tvm_linker`.
*	`tonos-cli` contract deployment tool. The tool is located at `tonos-cli/target/<debug or release>/tonos-cli`.
*	Compiler driver for C++. Due to TVM backend has very specific requirements for the optimization pipeline we strongly recommend using the tool rather than call clang manually. The driver is located at `TON-Compiler-build/bin/tvm-build++`.

## Brief introduction to TON and TVM and the terminology
Unlike common C++ programs, smart contracts are intended to be run in a blockchain. This implies that the code and, perhaps, data need to be stored permanently unless someone modifies or destroys them. In TON blockchain all contracts exchange messages between each other. The exchange is essentially asynchronous. When a contract receives a message, it parses it, and in case the message is sensible to a contract it generally invokes a user defined handler called a public method (which is usually a class method with public access specifier, but it doesn’t have to be implemented this way). When this tutorial refers to a public method it means a public method in terms of TVM rather than in terms of C++. One contract might send a message to another one and by means of this message call a public method asynchronously. Such a message is called an internal message (i.e. the sender is in the blockchain). Alternatively, an external tool might also create and send a message to a contract. Such a message is called an external message.
When a contract is handling a message, it has limited computation resources measured in gas. Gas price is deducted from contract balance and this balance is associated with the contract deployed into the network. However, even if a contract has outstanding balance, there is a hard limit on how much it can spend on a single incoming message, if this limit is exceeded, the contract is terminated even if the code it runs is well-formed.
To minimize the state which is transferred between contracts and stored in the blockchain, TVM does not have random access memory. The memory might be emulated by dictionaries, however, it’s quite expensive and often not practical taking into account limited gas supply. Thus a typical smart contract in C++ avoids using memory. Moreover, currently all the functions have to be inlined. That’s why `-O3` optimization and LTO are essential and it’s the pipeline `tvm-build++` implements.

## Environment setup
Prior to start developing a contract, we configure `PATH` to add all the tools we need:
```
export PATH=TON-Compiler-build/bin:TVM-linker-source/tvm_linker/target/<debug or release>:tonos-cli/target/<debug or release>:$PATH
```
`tvm-build++` needs additional treatment:
```
export TVM_LINKER=TVM-linker-source/tvm_linker/target/<debug or release>/tvm_linker #path to tvm_linker tool.
export TVM_INCLUDE_PATH=TON-Compiler-source/stdlib #path to the folder containing cpp-sdk directory.
export TVM_LIBRARY_PATH=TON-Compiler-source/stdlib #path to stdlib_cpp.tvm
```

## Hello, world!
A typical smart contract consists of two files:
*	contract interface description in a header file
*	contract implementation in a cpp-file
A contract might consist of more files if it's needed, but since the contract tends to be small, two files are often enough.
Let's start developing our first, `Hello, world!` contract by describing its interface.

### Describing a contract interface
A contract interface consists of three parts:
*	Public methods declarations.
*	Persistent data.
*	Events.
Public methods are functions that receive messages in the blockchain. There is a dedicated method called `constructor` which is called upon the contract deploy. The constructor is a must, otherwise the contract can not be deployed. The constructor, as well as other public methods, must only take arguments of types that are listed below:
*	`int_t<N>` - N-bits wide signed integer, 0 < N < 256.
*	`uint_t<N>` - N-bits wide unsigned integer, 0 < N < 257.
*	`MsgAddress` – message address which work for both internal or external messages.
*	`MsgAddressInt` – an internal message address.
*	`MsgAddressExt` – an external message address.
*	`dict_array<T, 32>` - a map representing an "array" stored in a dictionaly with 32-bits wide keys which are indices of the array. `T` must also belong to this list.
*	`dict_map<KeyT, ValueT>` - a map. `ValueT` must also belong to the list, `KeyT` must be `uint_t<N>`.
*	`sequence<uint_t<8>>` - a sequence of 8-bit unsigned values, it might also be seen as an "array" of 8-bits values; it’s usually cheaper to use sequentially stored data then maps.
*	`lazy<T>` - value of `T`, but the parsing is deferred until the actual value is needed. Only lazy<MsgAddress>, lazy<MsgAddressInt> and lazy<MsgAddressExt> are supported at the moment.
*	a compound type – a POD structure which only have data members of types from the list. When a compound type is used, it’s encoded the same way the sequence of its element does. Also note, that for the sake of ABI generation (see below) the names of the members are used, so be aware of possible collisions.
Aside from that, public methods might have an arbitrary signature. However, at the moment C++ for TVM does not support public method templates. For Hello, world contract all we need is the constructor and a method that sends an external message:
```
// Hello world interface
struct IHelloWorld {
  // Handle external messages only
  __attribute__((external))
  void constructor() = 1;

  // Handle external messages only
  __attribute__((external))
  uint_t<8> hello_world() = 2;
};
```
All the methods here are pure virtual ones, and N in `= N` designates their IDs. These IDs must be unique within a contract and an ID must also not be equal to 0.
Also methods have to be marked with at least one of the attributes:
*	external – the method handles external incoming messages
*	internal – the method handles internal incoming messages
*	getter – the method could be executed offchain, thus you can read persistent data without paying for it.
As you might have noticed, a public method could return. In such a case, the return value is interpreted as the value that needs to be sent via an external message, so an off-chain application can handle it. The type of the return value must also belong to the list above. Note that TVM supports multiple return values. Struct return type is the way to use the feature from C++.
`Hello, world!` contract doesn't need any persistent data member, however, currently, it's required to have at least one field of data otherwise you'd receive a weird looking error message. For `Hello, world!` contract, we use the following persistent data.
```
// Hello world persistent data
struct DHelloWorld {
  uint_t<1> x;
};
```
Finally, events might be interpreted as a kind of off-chain function calls. When a public method emits an event it works similar to another public method call implying that the message containing the function ID and the call parameters is emitted. However, in case of an event, this message is to be sent externally (i.e. outside of the blockchain), so an external handle could process it. Events are pure virtual methods as well, but they are not supposed to ever be defined or called. Also, their IDs must be different from the IDs of public methods. For Hello, world contract we don't need events at all:
```
// Hello world events
struct EHelloWorld {};
```
Putting all together, below is the complete listing of Hello, world contract interface.
```
#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Hello world interface
struct IHelloWorld {
  // Handle external messages only
  __attribute__((external))
  void constructor() = 1;

  // Handle external messages only
  __attribute__((external))
  uint_t<8> hello_world() = 2;
};

// Hello world persistent data
struct DHelloWorld {
  uint_t<1> x;
};

// Hello world events
struct EHelloWorld {};

}} // namespace tvm::schema
```

### Implementation
To implement a contract some SDK headers will be of help.
*	tvm/schema/message.hpp define message structure which is used in TON.
*	tvm/contract.hpp implement contract class and essential auxiliary functions to work with it.
*	tvm/smart_switcher.hpp implement smart_interface<T> which generates boilerplate code for parsing incoming messages, serializing method results and so on.
*	tvm/replay_attack_protection/timestamp.hpp implement timestamp based replay protection which is an essential thing which prevent the same message to be handles more than once.
After including the headers, we declare a class that represents the contract.
```
using namespace tvm::schema;
using namespace tvm;

class HelloWorld final : public smart_interface<IHelloWorld>,
                         public DHelloWorld {
…
};
```
To utilize smart switcher to not to write message parsing by yourself, a contract class must inherit from `start_interface<T>` where `T` is the type of the struct describing public methods (i.e. the interface) and from the struct describing the contract’s persistent data.
Implementation of `HelloWorld` is trivial:
```
public:
  __always_inline void constructor() final {}
  __always_inline uint_t<8> hello_world() final {return uint_t<8>(42);};

  // Function is called in case of unparsed or unsupported func_id
static __always_inline int _fallback(cell msg, slice msg_body) { return 0; };
```
Notes:
1.	`__always_inline` is essential here. Remember that the compiler will fail if a function fails to inline.
2.	The first two methods we’ve already seen. Aside from doing what is written they always perform replay protection check and accept the incoming message. By accepting a message, a contact agrees to pay for its processing and thus the computation the contract makes will not be discarded.
3.	The last method is called when either message ID is invalid or does not exist (e.g. when a contract sending it doesn’t use the ABI). Smart switcher isn’t able to help this method to parse a message, nor does it insert accept into it. Thus, by doing nothing there, the contract ignores ill-formed incoming external messages.
A couple of things needs to be added after the contract class is defined:
```
DEFINE_JSON_ABI(IHelloWorld, DHelloWorld, EHelloWorld);
```
Insert logic necessary to generate the ABI file which is required to work with the contract.
```
DEFAULT_MAIN_ENTRY_FUNCTIONS(HelloWorld, IHelloWorld, DHelloWorld, 1800)
```
Generate entry points function that transfer control flow to a public method. 1800 here is the argument which configure replay protection. 1800 it’s time in seconds which is recommended by the ABI manual.
Putting all together, here is the complete listing of the contract implementation.
```
#include "HelloWorld.hpp"

#include <tvm/contract.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>

using namespace tvm::schema;
using namespace tvm;

class HelloWorld final : public smart_interface<IHelloWorld>,
                         public DHelloWorld {
public:
  __always_inline void constructor() final {}
  __always_inline uint_t<8> hello_world() final {return uint_t<8>(42);};

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body) { return 0; }; };
DEFINE_JSON_ABI(IHelloWorld, DHelloWorld, EHelloWorld);

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(HelloWorld, IHelloWorld, DHelloWorld, 1800)
```

### Compilation and local testing
The code we wrote so far can be found at [Hello, world!](https://github.com/everx-labs/samples/blob/master/cpp/HelloWorld).
Let’s assume that we put the contract interface into `HelloWorld.hpp` and its implementation into `HelloWorld.cpp`. Compilation consist of two steps:
1.	Generating the ABI
```
clang++ -target tvm --sysroot=$TVM_INCLUDE_PATH -export-json-abi -o HelloWorld.abi HelloWorld.cpp
```
2.	Compiling and linking
```
tvm-build++.py --abi HelloWorld.abi HelloWorld.cpp --include $TVM_INCLUDE_PATH --linkerflags="--genkey key"
```
The first command produces the ABI file. Note that in case the contract uses an unsupported type, clang will silently generate "unknown" for it in the ABI and the contract will not link.
The second command compiles and links the contract. It produces address.tvc file and the file named “key”. Option `--genkey` produces keys to sign messages and store them to specified files (`<filename>` - for the private key and `<filename.pub>` for the public one). Currently all external messages have to be signed, otherwise an error number 40 will occur, so we need a key to sign if we plan to test a contract locally.

### Debugging locally
`tvm_linker` tool can be used to send messages to and to get messages from a contract. Please note though, that a contract modifies its persistent data stored in tvc file so that such a contract might no longer be deployable to the network. So, we recommend you to make a copy of the contract if you plan to test it locally, or alternatively recompile prior to the deployment.
When debugging in linker, the constructor is not called automatically and it supposed to be explicitly invoked by a programmer. In case the constructor does nothing like in `Hello, world!` it isn’t necessary, but for the sake of demonstration we still call it.
```
$ export ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
$ tvm_linker test $ADDRESS \
--abi-json HelloWorld.abi \
--abi-method constructor \
--abi-params '{}' \
--sign key
```
After executing the contract, the linker prints a long message. The most important part of it is that TVM is terminated with 0 exit code i.e. successfully. The second important part is how much gas were spent.
Let’s call `hello_world` method to ensure that it works as well.
```
tvm_linker test $ADDRESS \
--abi-json HelloWorld.abi \
--abi-method hello_world \
--abi-params '{}'  \
--sign key \
--decode-c6
```
Here we use `--decode-c6` option (please refer to `tvm_tools –help` for a complete manual on its command-line options) to display the outgoing message and ensure that the contract indeed sends a message containing 42 as a payload. You will find the outgoing message at the end of the linker output. The message body is displayed in hexadecimal form, and 0x2a = 42.

### Deploying and testing in the network
Testing in the network is somewhat similar to testing locally, but instead of the linker `tonos-cli` needs to be used and argument passing is a bit different. The deploying workflow is described in [README](https://github.com/everx-labs/samples/tree/master/cpp#contract-deployment) but we will repeat it once again here.
First, we need to recompile the contract since we used for linker tests.
Then copy newly generated tvc file (and rename it to `HelloWorld.tvc` for simplicity) and abi file to `tonos-cli/target/<debug or release>/`
After all the preparations, we can execute the following script
```
cd tonos-cli/target/<debug or release>/
cargo run genaddr HelloWorld.tvc HelloWorld.abi --genkey hw.key
```
The latter command returns the raw address of the contract. Now you can send (test) coins to it using any method described in [README](https://github.com/everx-labs/samples/tree/master/cpp#getting-test-coins). When contract balance is greater than 0, we can deploy the contract:
```
cargo run deploy --abi HelloWorld.abi HelloWorld.tvc '{}' --sign hw.key
```
And finally test `hello_world` method:
```
cargo run call –abi HelloWorld.abi "<raw address>" hello_world "{}" --sign hw.key
```
The command is supposed to output the message ending with
```
Succeded.
Result = {"output":{"value0":"0x2a"}}
```
## Authorization

### Interface and implementation
Now we are ready to extend the contract we just developed. The main issue of `Hello, world!` contract is that `hello_world` public method might be called by anybody. Because a method execution is not free, a stranger might spam the contract and thus spend all its balance. To prevent this, we need to introduce additional checks prior to accepting an incoming external message. To perform this check, the contract will do the following:
1.	Store the public key of the owner when deployed.
2.	Check the message signature against the key when `hello_world` is called.
The implementation is simple. First, we need to add persistent data to the contract.
```
// Hello world persistent data
struct DHelloWorld {
  uint_t<256> ownerKey;
};
```
Second, we need to add the following members to `HelloWorld` contract class:
```
// The compiler reads the key from the incoming message and stores is in
// pubkey_. So the key is available in a public method via tvm_pubkey().
unsigned pubkey_ = 0;
__always_inline void set_tvm_pubkey(unsigned pubkey) { pubkey_ = pubkey; }
__always_inline unsigned tvm_pubkey() const { return pubkey_; }
```
Third, we need to modify the constructor and `hello_world` method:
```
/// Deploy the contract.
__always_inline void constructor() final { ownerKey = tvm_pubkey(); }
__always_inline uint_t<8> hello_world() final {
  require(tvm_pubkey() == ownerKey, 101);
  return uint_t<8>(42);
}
```
Here we store the public key in the constructor, and then check it in `hello_world`. `101` in require call is the error code which needs to be greater than `100` to not interfere with virtual machine and C++ SDK error codes. The only issue remains is that the contract still accepts the incoming message before it checks the requirements. So, we don’t pay for the outgoing message if a stranger called it, but still pay for the rest of the execution. To fix that problem, we need to change the pure virtual method declaration:
```
__attribute__((external, noaccept))
uint_t<8> hello_world() = 2;
```
We also need to accept explicitly:
```
__always_inline uint_t<8> hello_world() final {
  require(tvm_pubkey() == ownerKey, 101);
  tvm_accept();
  return uint_t<8>(42);
};
```

### Deploying and testing in the network
This time we omit testing in the linker (you might do it by yourself, following the instructions from the corresponding subsection section of `Hello, world!` contract). For testing in the network, we generate another key when deploying and then check if we can get result using this key and the previous one which should not be valid.
Recompile and copy the contract to `tonos-cli/target/<debug or release>/` similar to the previous contract. Then run:
```
cd tonos-cli/target/<debug or release>/
cargo run genaddr HelloWorld.tvc HelloWorld.abi --genkey auth.key
#send coins to the contract address somehow
cargo run deploy --abi HelloWorld.abi HelloWorld.tvc '{}' --sign auth.key
cargo run call –abi HelloWorld.abi "<raw address>" hello_world "{}" --sign hw.key
cargo run call –abi HelloWorld.abi "<raw address>" hello_world "{}" --sign auth.key
```
The first call will fail and terminate by timeout. Any uncaught exception that occurs prior to accept will not be shown, because currently the node doesn’t support such a feature. To properly diagnose it, you should install TON OS SE and use it for debugging, which is out of scope of this tutorial. The second call should successfully return 0x2a.

## Message exchange

### Interface and implementation
Finally, we are ready to implement more complex contracts that exchange messages between each other. Giver is a good example of such a contract. We ask the reader to familiarize yourself with the code. Here we only provide some gist of it:
1.	An internal public method could be declared the same way the external is, but it’s marked with `internal` attribute. An internal method use, the incoming message balance rather than the contract's balance to compute, so unlike an external method, it doesn't need to accept a message.
2.	`tvm/contract_handle.hpp` provides function to call a method of another contract. To do so, it needs the callee contract’s interface class defifinition, so that was the reason for separate cpp and hpp part of the contract implementation. The syntax is generally the following:
```
auto handle = contract_handle<ICallee>(callee_address);
handle(message_balance, message_flags).call<&ICallee::method_name>(parameters…);
```
The first line constructs the handle for the contract. A contract might be called though it. The second line configures the call via `operator()` and then performs it. `operator()` is optional, by default this configuration guarantees that if the sender has enough balance the message will carry 1 000 000 units of money.

### Debugging locally
Unlike the previous testing scenarios, we need to check how internal messages work. To do so, first we need generate an outgoing message. Let’s call `get_money` method of `Client` contract and ask the `Giver` with address `<Giver address>` 42 000 units of money:
```
tvm_linker test <Client address> \
--abi-json Client.abi \
--abi-method get_money \
--abi-params "{\"giver\":\"<Giver address>\", \"balance\":42000}" \
--sign client \
--decode-c6
```
After the execution, the message is encoded in one of the last lines of the output:
```
body  : bits: 288   refs: 0   data: 00000002000000000000000000000000000000000000000000000000000000000000a410
```
The message is `00000002000000000000000000000000000000000000000000000000000000000000a410`
The linker does not automatically send this message to Giver contract, so we need to request it to do so:
```
tvm_linker test <Giver address> \
--src "<Client address> " \
--internal <message balance> \
--body 00000002000000000000000000000000000000000000000000000000000000000000a410 \
--decode-c6
```
`--src` here is the sender address. It might be omitted if the receiver doesn’t check where the message came from.

### Deploying and testing in the network
When testing in a real network, you don’t need to send internal messages – only external ones. So the process does not differ much. However, [ton.live](https://net.ton.live/) becomes essential to see all incoming and outgoing messages for a contract. All you need is to specify the raw addess, and look at the logs. 
