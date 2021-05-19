pragma ton-solidity >= 0.44.0;
pragma AbiHeader expire;

contract Sink {

    uint public m_counter;

    constructor() public onlyOwnerAccept {
    }

    modifier onlyOwnerAccept {
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function inc(uint delta) public {
        m_counter += delta;
    }

    function incAndGetCount(uint delta) public responsible returns (uint) {
        m_counter += delta;
        return{value: 0, flag: 64} m_counter;
    }
}
