pragma ton-solidity >=0.32.0;
pragma AbiHeader expire;

import "20_interface.sol";

contract Sink is ISink {

    uint public counter = 0;
    uint a;
    uint b;


    receive() external {
        ++counter;
    }

    function receive0(uint _a, uint _b) external override {
        ++counter;
        a = _a;
        b = _b;
    }

    modifier onlyOwner {
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function testFlag64(address addr, uint mode) external pure onlyOwner {
        if (mode == 0)
            IBomber(addr).testValue0Flag64{value: 1 ton}();
        else if (mode == 1)
            IBomber(addr).testValue1Flag64{value: 1 ton}();
        else if (mode == 2)
            IBomber(addr).testValue1Flag65{value: 1 ton}();
    }

}


