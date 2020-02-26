pragma solidity >=0.5.0;

contract ContractDeployer {

	// Runtime functions:

	// Function that inserts public key into contracts data field.
	function tvm_insert_pubkey(TvmCell cellTree, uint256 pubkey) private pure returns(TvmCell /*contract*/)  {}

	// Functions to deploy a contract.
	function tvm_deploy_contract(TvmCell my_contract, address addr, uint128 gram,
								uint32 constuctor_id,
								uint32 constuctor_param0,
								uint constuctor_param1) private pure { }
	function tvm_deploy_contract(TvmCell my_contract, address addr, uint128 grams,
								TvmCell payload) private pure { }

	// Function to generate StateInit from code and data cells.
	function tvm_build_state_init(TvmCell /*code*/, TvmCell /*data*/) private pure returns (TvmCell /*cell*/) { }

	// State variable storing the address of deployed contract.
	address contractAddress;

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

	// First variant of contract deploying

	// State variable storing the StateInin of deployed contract. It contains contract's code and data.
	TvmCell contractStateInit;

	function setContract(TvmCell _contract) public alwaysAccept {
		contractStateInit = _contract;
	}

	function deploy(uint256 pubkey, uint128 gram_amount,
					uint32 constuctor_id, uint32 constuctor_param0, uint constuctor_param1) public alwaysAccept returns (address) {
		TvmCell contractWithKey = tvm_insert_pubkey(contractStateInit, pubkey);
		// tvm.hash() - Runtime function that computes the representation hash ot TvmCell.
		address addr = address(tvm.hash(contractWithKey));
		tvm_deploy_contract(contractWithKey, addr, gram_amount, constuctor_id, constuctor_param0, constuctor_param1); //create internal msg
		contractAddress = addr;
		return addr;
	}


	// Second variant of contract deploying

	// State variable storing the code of deployed contract.
	TvmCell contractCode;

	function setCode(TvmCell _code) public alwaysAccept {
		contractCode = _code;
	}

	function deploy2(TvmCell data, uint128 gram_amount, uint32 constuctor_id,
		             uint32 constuctor_param0, uint constuctor_param1) public alwaysAccept returns (address) {
		TvmCell contr = tvm_build_state_init(contractCode, data);
		// tvm.hash() - Runtime function that computes the representation hash ot TvmCell.
		address addr = address(tvm.hash(contr));
		tvm_deploy_contract(contr, addr, gram_amount, constuctor_id, constuctor_param0, constuctor_param1); //create internal msg
		contractAddress = addr;
		return addr;
	}

	// Third variant of contract deploying

	function deploy3(TvmCell contr, address addr, uint128 gram_amount, TvmCell payload) public alwaysAccept returns (address) {
		// payload - is body of message
		tvm_deploy_contract(contr, addr, gram_amount, payload); //create internal msg
		contractAddress = addr;
		return addr;
	}
}
