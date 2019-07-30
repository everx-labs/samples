Contract MyContract (contract02-a) demonstrates how to call a remote contract by passing an integer. It particular, this contract sends an instance of the **AnotherContract** remote class and calls its method specified in the contract02-b.

```
 // call function of remote contract with parameter
        anotherContract.remoteMethod(257);
 ```    
The remote contract (contract02-b) saves this integer in persistent variable.
```

	// and save this value in persistent variable 'm_value' of this contract
  
function remoteMethod(uint64 value) public {
		m_value = value;
		return;
```
