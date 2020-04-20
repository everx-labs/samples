pragma solidity >=0.5.0;

contract ContractDeployer {

	// Struct to store information about deployed contracts.
	struct DeployedContract {
		address addr;
		TvmCell stateInit;
		uint256 pubkey;
	}

	// Deployed contracts database.
	mapping(uint => DeployedContract) contracts;
	uint public lastID = 0;

	// Modifier that allows public function to accept external calls only from the contract owner.
	modifier acceptOnlyOwner {
		require(tvm.pubkey() == msg.pubkey(), 101);
		tvm.accept();
		_;
	}


	// First variant of contract deployment.
	function deployWithPubkey(TvmCell stateInit, uint256 pubkey, uint128 initial_balance,
	uint32 constructor_id, uint32 constructor_param0, uint constructor_param1) public acceptOnlyOwner returns (address, uint) {
		// Runtime function that inserts public key into contracts data field.
		TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, pubkey);

		// tvm.hash() - Runtime function that computes the representation hash ot TvmCell.
		address addr = address(tvm.hash(stateInitWithKey));

		// Functions to deploy a contract and call it's constructor.
		tvm.deployAndCallConstructor(stateInitWithKey, addr, initial_balance, constructor_id, constructor_param0, constructor_param1);

		uint newID = lastID;
		contracts[newID] = DeployedContract(addr, stateInitWithKey, pubkey);
		lastID = newID + 1;
		return (addr, newID);
	}


	// Second variant of contract deployment.
	function deployFromCodeAndData(TvmCell code, TvmCell data, uint128 initial_balance,
	uint32 constructor_id, uint32 constructor_param0, uint constructor_param1) public acceptOnlyOwner returns (address, uint) {
		// Runtime function to generate StateInit from code and data cells.
		TvmCell stateInit = tvm.buildStateInit(code, data);

		// tvm.hash() - Runtime function that computes the representation hash ot TvmCell.
		address addr = address(tvm.hash(stateInit));

		// Functions to deploy a contract and call it's constructor.
		tvm.deployAndCallConstructor(stateInit, addr, initial_balance, constructor_id, constructor_param0, constructor_param1);

		// In this function we deploy contract without public key, that's why we store struct with zero pubkey.
		uint newID = lastID;
		contracts[newID] = DeployedContract(addr, stateInit, 0);
		lastID = newID + 1;
		return (addr, newID);
	}


	// Third variant of contract deployment.
	function deployWithMsgBody(TvmCell stateInit, address addr, uint128 initial_balance, TvmCell payload) public acceptOnlyOwner
	returns (address, uint) {
		// Runtime function to deploy contract with prepared msg body for constructor call.
		tvm.deploy(stateInit, addr, initial_balance, payload);

		uint newID = lastID;
		contracts[newID] = DeployedContract(addr, stateInit, 0);
		lastID = newID + 1;
		return (addr, newID);
	}

	// Function that allows to get address of the last deployed contract.
	function getAddressOfLastDeployedContract() public view acceptOnlyOwner returns (address) {
		DeployedContract contr = contracts[lastID - 1];
		return contr.addr;
	}

	// Function that allows to get information about contract with given ID.
	function getContractInfo(uint ID) public view acceptOnlyOwner returns (bool, address, TvmCell, uint256) {
		(bool exists, DeployedContract contr) = contracts.fetch(ID);
		if (exists)
			return (true, contr.addr, contr.stateInit, contr.pubkey);
		TvmCell cell;
		return (false, address(0), cell, 0);
	}
}
