pragma ton-solidity >= 0.44.0;
pragma AbiHeader expire;

import "22_sink.sol";

contract Sender {

    uint public m_value;

    constructor() public onlyOwnerAccept {
    }

    modifier onlyOwnerAccept {
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function testSend(address dest) onlyOwnerAccept public pure {
        // generates cell which contains message which calls another contract by internal outbound message
        TvmCell message = tvm.buildIntMsg({
            dest: dest,
            value: 1 ton,
            call: {Sink.inc, 5, 22},
            bounce: true
        });

        for (int i = 0; i < 10; ++i) {
            tvm.sendrawmsg(message, 0);
        }
    }

    function testResponsibleSend(address dest) onlyOwnerAccept public pure {
        TvmCell message = tvm.buildIntMsg({
            dest: dest,
            value: 1 ton,
            call: {Sink.incAndGetCount, Sender.onReceiveCount, 15, 22}, // here we must set callback function 'onReceiveCount'
                                                                        // because function `incAndGetCount` is responsible
            bounce: true
        });

        tvm.sendrawmsg(message, 0);
    }

    function onReceiveCount(uint count) public {
        // just save received value in state variable
        m_value = count;
    }
}
