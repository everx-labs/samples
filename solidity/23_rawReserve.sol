pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

contract Reserve {

    mapping(uint => uint) m_map;

    constructor() onlyOwnerAccept {
    }

    modifier onlyOwnerAccept {
        require(tvm.pubkey() != 0 && tvm.pubkey() == msg.pubkey());
        tvm.accept();
        _;
    }

    function doHardWork() private {
        for (uint i = 0; i < 50; ++i) {
            m_map[i] = i * i;
        }
    }

    function reserve0() external {
        doHardWork();
        // Contract reserves exactly 1 ever.
        // If contract balance is less than 1 ever, an exception is thrown at the action phase.
        tvm.rawReserve(1 ever, 0);
        msg.sender.transfer({value: 0, flag: 128}); // sends all rest balance
        // after a successful call of `reserve0` contract's balance will equal to 1 ever
    }

    function reserve1() external {
        doHardWork();
        // Contract reserves all but 1 ever from the remaining balance of the account.
        // If contract balance is less than 1 ever, an exception is thrown at the action phase.
        tvm.rawReserve(1 ever, 1);
        msg.sender.transfer({value: 0, flag: 128});
        // Let's consider that the contract had balance equal to 5 ever before the function `reserve1`
        // was called by an internal message with value of 0.5 ever.
        // `doHardWork` function call consumes gas, which is roughly equal to 0.2 ever in workchain.
        // After compute phase contract's balance will be approximately equal to 5 + 0.5 - 0.2 = 5.3 ever.
        // `rawReserve` will reserve 5.3 - 1 = 4.3 ever.
        // `msg.sender.transfer` will send `all_balance` - `reserved_value` = 5.3 - 4.3 = 1 ever
        // Finally, after a successful call of `reserve1` contract's balance will be approximately equal to 4.3 ever
    }

    function reserve2() external {
        doHardWork();
        // contract reserves at most 1 ever. Never throws exceptions
        tvm.rawReserve(1 ever, 0 + 2);
        msg.sender.transfer({value: 0, flag: 128}); // sends all rest balance
        // after a successful call of `reserve2` contract's balance will be less than or equal to 1 ever
    }

    function reserve3() external {
        doHardWork();
        // Contract reserves all but 1 ever from the remaining balance of the account
        // or 0 ever if remaining balance less than 1 ever.
        // Never throws exceptions.
        tvm.rawReserve(1 ever, 1 + 2);
        msg.sender.transfer({value: 0, flag: 128});
    }

    function reserve12() external {
        doHardWork();
        tvm.rawReserve(0.3 ever, 4 + 8);
        msg.sender.transfer({value: 0, flag: 128});
        // Let's consider that the contract had balance equal to 5 ever before the function `reserve4`
        // was called by an internal message with value of 0.5 ever.
        // It means that original_balance (see API.md for details) is approximately equal to 5 ever.
        // `tvm.rawReserve` will reserve 5 - 0.3 = 4.7 evers
        // Throws an exception if at the action phase there is not enough funds.
    }
}
