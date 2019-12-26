pragma solidity ^0.5.0;

// Type TvmCell is only supported in the new experimental ABI encoder.
pragma experimental ABIEncoderV2;

contract ContractDeployer {

	// Struct that is used to process TVM internal type Cell.
	struct TvmCell {
		uint _;
	}

	// Runtime functions:

	// Function that inserts public key into contracts data field.
	function tvm_insert_pubkey(TvmCell memory cellTree, uint256 pubkey) private pure returns(TvmCell memory /*contract*/)  {}

	// Function that counts hash of the TVM Cell.
	function tvm_hashcu(TvmCell memory cellTree) pure private returns (uint256) { }

	// Functions to deploy a contract.
	function tvm_deploy_contract(TvmCell memory my_contract, address addr, uint128 gram,
								uint32 constuctor_id,
								uint32 constuctor_param0,
								uint constuctor_param1) private pure { }
	function tvm_deploy_contract(TvmCell memory my_contract, address addr, uint128 grams,
								TvmCell memory payload) private pure { }

	// Function to generate StateInit from code and data cells.
	function tvm_build_state_init(TvmCell memory /*code*/, TvmCell memory /*data*/) private pure returns (TvmCell memory /*cell*/) { }

	// Function that allows contract to process inbound messages spending
	// it's own resources (it's necessary if contract should process all inbound messages,
	// not only those that carry value with them).
	function tvm_accept() private pure {}

	// Function that constructs address from wid and address integers.
	function tvm_make_address(int8 wid, uint256 addr) private pure returns (address payable) {}

	// State variable storing the address of deployed contract.
	address contractAddress;

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		tvm_accept(); _;
	}


	// First variant of contract deploying

	// State variable storing the StateInin of deployed contract. It contains contract's code and data.
	TvmCell contractStateInit;

	function setContract(TvmCell memory _contract) public alwaysAccept {
		contractStateInit = _contract;
	}

	function deploy(uint256 pubkey, uint128 gram_amount,
					uint32 constuctor_id, uint32 constuctor_param0, uint constuctor_param1) public alwaysAccept returns (address) {
		TvmCell memory contractWithKey = tvm_insert_pubkey(contractStateInit, pubkey);
		address addr = tvm_make_address(0, tvm_hashcu(contractWithKey));
		tvm_deploy_contract(contractWithKey, addr, gram_amount, constuctor_id, constuctor_param0, constuctor_param1); //create internal msg
		contractAddress = addr;
		return addr;
	}


	// Second variant of contract deploying

	// State variable storing the code of deployed contract.
	TvmCell contractCode;

	function setCode(TvmCell memory _code) public alwaysAccept {
		contractCode = _code;
	}

	function deploy2(TvmCell memory data, uint128 gram_amount, uint32 constuctor_id,
		             uint32 constuctor_param0, uint constuctor_param1) public alwaysAccept returns (address) {
		TvmCell memory contr = tvm_build_state_init(contractCode, data);
		address addr = tvm_make_address(0, tvm_hashcu(contr));
		tvm_deploy_contract(contr, addr, gram_amount, constuctor_id, constuctor_param0, constuctor_param1); //create internal msg
		contractAddress = addr;
		return addr;
	}

	// Third variant of contract deploying

	function deploy3(TvmCell memory contr, address addr, uint128 gram_amount, TvmCell memory payload) public alwaysAccept returns (address) {
		// payload - is body of message
		//address addr = address(tvm_hashcu(contr));
		tvm_deploy_contract(contr, addr, gram_amount, payload); //create internal msg
		contractAddress = addr;
		return addr;
	}
}
