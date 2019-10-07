This sample  demonstrates the logic of transfer request and response.
The MyContract (contract04-a) contract calls to the other contract (contract04-b) and initiates a method there. 

The remote contract (contract04-b) transfers the requested 'value' in Grams to the caller in response. 

The first contract also stores the number of calls to the method in question (i.e. stores the number of transactions) in its persistent memory (m_counter is a persistent variable).

Also note how the **tvm_togstr** function for sending money is declared and used. **msg.sender.transfer(value)** allows transferring the requested amount to the caller address.
