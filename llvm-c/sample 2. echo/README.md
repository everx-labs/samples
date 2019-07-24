# Echo contract

This contract just keeps the last input value in a persistent variable, 
so one may check the results of `compute` method invocation in account
state by analyzing `getaccount` command output.

This is the second contract in the samples, look into `hello_world` 
contract source code and readme for additional info.

## Methods

### Method `compute`
#### Input values
##### Argument `x`
* ABI type: `uint64`
* C type: `unisnged`
* Description: value to be copied into persistent memory and 
returned in external message.

#### Output values
* ABI type: `uint64`
* C type: `unisnged`
* Description: equal to the input value `x`.

#### Notes
This method has input value, so `--abi-params` argument should be specified
differently (in comparison with `tvm_linker` invocation for `compute` method
in `hello_world` contract):

    ... --abi-params "{\"x\":<value>}" ...

Here, `<value>` is the value for the field — an integer number in decimal format.
The field name is specified in screened quotes to be properly transferred to linker.

## Persistent data
### Field `x_persistent`
* C type: `unsigned`
* Description: keeps the argument, passed to the last
invocation of `compute`.