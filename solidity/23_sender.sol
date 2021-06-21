pragma ton-solidity >= 0.44.0;
pragma AbiHeader expire;

import "23_rawReserve.sol";

contract MyContract {

    modifier onlyOwnerAccept {
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function transfer(address addr, uint128 value) public pure onlyOwnerAccept {
        addr.transfer({value: value, flag: 1});
    }

    function send(address addr, uint mode) public pure onlyOwnerAccept {
        if (mode == 0) {
            Reserve(addr).reserve0{value: 0.5 ton, flag: 1}();
        } else if (mode == 1) {
            Reserve(addr).reserve1{value: 0.5 ton, flag: 1}();
        } else if (mode == 2) {
            Reserve(addr).reserve2{value: 0.5 ton, flag: 1}();
        } else if (mode == 3) {
            Reserve(addr).reserve3{value: 0.5 ton, flag: 1}();
        } else if (mode == 4) {
            Reserve(addr).reserve12{value: 0.5 ton, flag: 1}();
        } else {
            revert(101);
        }
    }


}
