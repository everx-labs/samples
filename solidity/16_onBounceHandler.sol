pragma solidity >= 0.6.0;

// Interface of the contract we want to interact with.
abstract contract IBounceCallee {
	function receiveMoney(uint128 value) public payable virtual;
	function receiveValues(uint16 value1, bool value2, uint64 value3) public virtual;
}


// Contract that can handle errors during intercontract communication.
contract BounceCaller {

	// State variables:
	uint bounceCounter;				// Number of onBounce function calls;

	// Saved arguments of function calls which were handled with failure.
	uint16 invalidValue1; 
	bool invalidValue2;
	uint64 invalidValue3;
	uint128 invalidMoneyAmount;

	modifier alwaysAccept {
		tvm.accept();
		_;
	}

	// Function onBounce is executed on inbound messages with set <bounced> flag.
	// This function takes the body of the message as an argument.
	onBounce(TvmSlice slice) external {
		// Increase the counter.
		bounceCounter++;

		// Start decoding the message. First 32 bits store the function id.
		uint32 functionId = slice.decode(uint32);

		// Api function tvm.functionId() allows to calculate function id by function name.
		if (functionId == tvm.functionId(IBounceCallee.receiveMoney)) {
			//Function decodeFunctionParams() allows to decode function parameters from the slice.
			// After decoding we store the arguments of the function in the state variables.
			invalidMoneyAmount = slice.decodeFunctionParams(IBounceCallee.receiveMoney);
		} else if (functionId == tvm.functionId(IBounceCallee.receiveValues)) {
			(invalidValue1, invalidValue2, invalidValue3) = 
			slice.decodeFunctionParams(IBounceCallee.receiveValues);
		}
	}

	// Function that calls another contract function and attaches some currency to the call.
	function sendMoney(address callee, uint128 amount) public payable alwaysAccept {
		IBounceCallee(callee).receiveMoney.value(amount)(amount);
	}

	// Funciton that calls another contract function with arbitrary arguments.
	function sendValues(address callee, uint16 value1, bool value2, uint64 value3) public pure
		alwaysAccept {
		IBounceCallee(callee).receiveValues(value1, value2, value3);
	}

	// Function to get state variables.
	function getData() public view alwaysAccept returns (uint, uint16, bool, uint64, uint128) {
		return (bounceCounter, invalidValue1, invalidValue2, invalidValue3, invalidMoneyAmount);
	}

}
