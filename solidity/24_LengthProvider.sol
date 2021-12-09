pragma ton-solidity >= 0.44.0;
pragma AbiHeader expire;

contract LengthProvider {
    function getLength(uint64 id) pure external responsible returns(uint64, uint32) {
        return{value: 0, flag: 64}(id, 43);
    }
}
