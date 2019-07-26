MyContract (contract06-a) is responsible for storing information about allowed credits for different contracts.
This is stored in 

	mapping(address => ContractInfo) m_allowed;
	
member field. It is supposed that owner of a contract calls setAllowance() external method to specify the limits.
It also proceeds getCredit() internal messages replying with the amount of credit allowed.

RemoteContract (contract06-b) is client requesting for a credit. It can accept getMyCredit() external requests,
forwards the request to the specified account of type IMyContract and stores the answer to m_answer member field.
The latter field can be checked via getaccount feature of test-lite-client.

