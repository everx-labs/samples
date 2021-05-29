pragma ton-solidity >= 0.44.0;
pragma AbiHeader expire;

contract Sink {

    uint public m_counter;
    uint public m_value;


    constructor() public onlyOwnerAccept {
    }

    modifier onlyOwnerAccept {
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function inc(uint delta, uint value) public {
        m_counter += delta;
        m_value = value;
    }

    function incAndGetCount(uint delta, uint value) public responsible returns (uint) {
        m_counter += delta;
        m_value = value;
        return{value: 0, flag: 64} m_counter;
    }
}
