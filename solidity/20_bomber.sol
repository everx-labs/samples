pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

import "20_interface.sol";

contract Bomber is IBomber {

    uint constant param0 = 10;
    uint constant param1 = 100;

    mapping(uint => uint) map;

    constructor () {
        tvm.accept();
    }

    modifier onlyOwner {
        // Check that function is called by external message
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function testSend0(address addr) external view onlyOwner {
        // Bomber sends 1 ever but Sink will get less than 1 ever (~ 0.998 ever).
        // Because forward fee is subtracted from 1 ever
        ISink(addr).receive0{value: 1 ever, flag: 0}(param0, param1);
    }

    function testSend1(address addr) external view onlyOwner {
        // Bomber sends 1 ever and Sink will get 1 ever exactly.
        // Forward fee is subtracted from balance of this contract.
        ISink(addr).receive0{value: 1 ever, flag: 1}(param0, param1);
    }

    function testSend128(address addr) external view onlyOwner {
        // Bomber sends all its balance and Sink will get all that funds minus forward fee.
        // The Bomber's balance will be equal to zero.
        ISink(addr).receive0{value: 0, flag: 128}(param0, param1);
        // Note: parameter "value" is ignored by the virtual machine. It can be set to any value, for example zero.
    }

    function testSend160(address addr) external view onlyOwner {
        // Bomber sends all its balance and Sink will get all that funds minus forward fee.
        // The Bomber's balance will be equal to zero and the contract will be destroyed.
        ISink(addr).receive0{value: 0, flag: 128 + 32}(param0, param1);
        // Note: parameter "value" is ignored by the virtual machine. It can be set to any value, for example zero.
        // Note: After destroying the contract can be redeployed on the same address.
    }

    // The function can be called only by internal message (in function there is no `tvm.accept()`)
    function testValue0Flag64() external override {
        // This function was called by internal message. In this function works with mapping. In this case amount of
        // used gas depends on size of the mapping. Caller doesn't know how much value should be attached to cover gas.
        // So, caller can attach some big value and this contract will return change.
        map[rnd.next()] = rnd.next();
        // Return change.
        // Forward fee is subtracted from change. See also function `testSend0`.
        ISink(msg.sender).receive0{value: 0, flag: 64}(param0, param1);
    }

    function testValue1Flag64() external override {
        map[rnd.next()] = rnd.next();
        // Returns change and sends 1 ever.
        // Forward fee is subtracted from (change + 1 ever). See also function `testSend0`.
        ISink(msg.sender).receive0{value: 1 ever, flag: 64}(param0, param1);
    }

    function testValue1Flag65() external override {
        map[rnd.next()] = rnd.next();
        // Returns change and sends 1 ever.
        // Forward fee is subtracted from Bomber's balance. See also function `testSend1`
        ISink(msg.sender).receive0{value: 1 ever, flag: 64 + 1}(param0, param1);
    }

    function testFlag2(address addr) external view onlyOwner {
        // Contract sends 3 messages with values: 1 ever, 1e9 ever and 1 ever.
        // Let contract has balance equal to 5 ever. Then it's obvious that it can't send 1e9 ever. It should cause fail
        // of action phase. But the second message has flag: 2. It means that any errors arising while processing this
        // message during the action phase should be ignored.
        // That's why contract will send successfully the first and third messages. The second message will be ignored.
        ISink(addr).receive0{value: 1 ever, flag: 0}(param0, param1);
        ISink(addr).receive0{value: 1e9 ever, flag: 2}(param0, param1);
        ISink(addr).receive0{value: 1 ever, flag: 0}(param0, param1);
    }
}
