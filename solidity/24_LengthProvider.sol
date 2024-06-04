pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

contract LengthProvider {
    constructor () {
        tvm.accept();
    }

    function getLength(uint64 id) pure external responsible returns(uint64, uint32) {
        return{value: 0, bounce: false, flag: 64}(id, 43);
    }
}
