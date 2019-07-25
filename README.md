# New sample contracts in Solidity:

* [contract01](https://github.com/tonlabs/samples/tree/solidity-project/example-01): demonstrates how to save data to a persistent storage. Use the ***getaccount*** command to obtain the contract state;
* [contract02](https://github.com/tonlabs/samples/tree/solidity-project/example-02): demonstrates how to call a remote contract by passing an integer. The remote contract saves this integer and it is available for checking;
* [contract03](https://github.com/tonlabs/samples/tree/solidity-project/example-03): demonstrates how to use the ***msg.sender*** function to get address of a contract that called you;
* [contract04](https://github.com/tonlabs/samples/tree/solidity-project/example-04): demonstrates how to transfer grams with the ***address.transfer()*** function;
* [contract05](https://github.com/tonlabs/samples/tree/solidity-project/example-05): callback implementation. One contract calls another one and gets response with a callback;
* [contract06](https://github.com/tonlabs/samples/tree/solidity-project/example-06): demonstrates implementation of mappings, external methods and callbacks as well.
    
# New sample contracts in C:

* [example-1-hello-world](https://github.com/tonlabs/samples/tree/c-project/example-1-hello-world): simplest contract in the repository, it adds 2 and 2 and returns the sum as an external message. This contract is a good starting point.
* [example-2-echo](https://github.com/tonlabs/samples/tree/c-project/example-2-echo): stores the last input value in a persistent variable. This allows the user to check the results of the contract's method invocations using ***getaccount*** command.
* [example-3-transfer-80000001](https://github.com/tonlabs/samples/tree/c-project/example-3-transfer-80000001): sends 0xAAAA nanograms (43960 in decimal)
to the account 0x80000001. This contract shows how to create and send internal messages.
