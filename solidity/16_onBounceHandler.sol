pragma solidity >= 0.6.0;

// Interface of the contract we want to interact with.
interface AnotherContract {
	function receiveMoney(uint128 value) external;
	function receiveValues(uint16 value1, bool value2, uint64 value3) external;
}


// Contract that can handle errors during intercontract communication.
contract MyContract {

	// State variables:
	uint bounceCounter;				// Number of onBounce function calls;

	// Saved arguments of function calls which were handled with failure.
	uint16 invalidValue1;
	bool invalidValue2;
	uint64 invalidValue3;
	uint128 invalidMoneyAmount;

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier onlyOwnerAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// Function onBounce is executed on inbound messages with set <bounced> flag. This function can not be called by
	// external/internal message
	// This function takes the body of the message as an argument.
	onBounce(TvmSlice slice) external {
		// Increase the counter.
		bounceCounter++;

		// Start decoding the message. First 32 bits store the function id.
		uint32 functionId = slice.decode(uint32);

		// Api function tvm.functionId() allows to calculate function id by function name.
		if (functionId == tvm.functionId(AnotherContract.receiveMoney)) {
			//Function decodeFunctionParams() allows to decode function parameters from the slice.
			// After decoding we store the arguments of the function in the state variables.
			invalidMoneyAmount = slice.decodeFunctionParams(AnotherContract.receiveMoney);
		} else if (functionId == tvm.functionId(AnotherContract.receiveValues)) {
			(invalidValue1, invalidValue2, invalidValue3) = slice.decodeFunctionParams(AnotherContract.receiveValues);
		}
	}

	// Function that calls another contract function and attaches some currency to the call.
	function sendMoney(address dest, uint128 amount) public onlyOwnerAndAccept {
		AnotherContract(dest).receiveMoney{value: amount}(amount);
	}

	// Function that calls another contract function with arbitrary arguments.
	function sendValues(address dest, uint16 value1, bool value2, uint64 value3) public view onlyOwnerAndAccept {
		AnotherContract(dest).receiveValues(value1, value2, value3);
	}

	/*
	 * Public Getters
	 */
	// Function to get state variables.
	function getData() public view returns (uint c, uint16 v1, bool v2, uint64 v3, uint128 f) {
		return (bounceCounter, invalidValue1, invalidValue2, invalidValue3, invalidMoneyAmount);
	}

}
