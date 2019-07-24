# Hello, world!

This is the simplest contract in the repository, it adds 2 and 2 and 
returns the sum as an external message. Since parsing of external messages 
is not yet supported, this contract is for toolchain testing purposes
only.

## Methods

### Method `compute`
#### Input values
None
#### Output value
* ABI type: `uint64`
* C type: `unsinged`
* Value description: 4 (sum of 2 and 2)
#### Notes
To call this method, one needs to send a message to the contract.
All messages are built by tvm_linker.
To build such message, invoke the following command:

    tvm_linker message <account> -w 0 --abi_file hello_world.abi 
        --abi_method compute --abi_params "{}"

The parameters of the command have the following meaning:

* `<account>` is the contract account number. It is a 256-bit number in hex format, 
file `<account>.tvc` with the compiled contract is created by the compiler at the 
moment of its deployment, and it should present in the current directory. 

* `-w` parameter specifies the workchain number for the message. It should be 0.

* `--abi_file` parameter should point to ABI interface of the contract. If you are
working from subdirectory `hello_world_build.c`, it should point to the parent catalog:
`--abi_file ../hello_world.abi`.

* `--abi_method` is used to specify the name of the method to be called. In this example
it is `compute`.

* `--abi_params` is used to specify parameters for the method. Since `compute` method has no
parameters, empty curve braces should be specified here. The braces should be
quoted to be properly understood by shell.

After the command invocation, a file `xxx_msg_body.boc` is created with the compiled
message. This file is to be sent to the node.

## Persistent data

None