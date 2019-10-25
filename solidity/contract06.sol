pragma solidity ^0.5.0;

//Contract interface file

contract IMyContract {
	function method(IMyRemoteContract anotherContract) public;
}

contract IMyRemoteContract {
	function remoteMethod() public payable;
}

