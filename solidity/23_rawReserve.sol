pragma ton-solidity >= 0.44.0;
pragma AbiHeader expire;

contract Reserve {

    mapping(uint => uint) m_map;

    constructor() public onlyOwnerAccept {
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

    function reserve0() public {
        doHardWork();
        // Contract reserves exactly 1 ton.
        // If contract balance is less than 1 ton, an exception is thrown at the action phase.
        tvm.rawReserve(1 ton, 0);
        msg.sender.transfer({value: 0, flag: 128}); // sends all rest balance
        // after a successful call of `reserve0` contract's balance will equal to 1 ton
    }

    function reserve1() public {
        doHardWork();
        // Contract reserves all but 1 ton from the remaining balance of the account.
        // If contract balance is less than 1 ton, an exception is thrown at the action phase.
        tvm.rawReserve(1 ton, 1);
        msg.sender.transfer({value: 0, flag: 128});
        // Let's consider that the contract had balance equal to 5 ton before the function `reserve1`
        // was called by an internal message with value of 0.5 ton.
        // `doHardWork` function call consumes gas, which is roughly equal to 0.2 ton in workchain.
        // After compute phase contract's balance will be approximately equal to 5 + 0.5 - 0.2 = 5.3 ton.
        // `rawReserve` will reserve 5.3 - 1 = 4.3 ton.
        // `msg.sender.transfer` will send `all_balance` - `reserved_value` = 5.3 - 4.3 = 1 ton
        // Finally, after a successful call of `reserve1` contract's balance will be approximately equal to 4.3 ton
    }

    function reserve2() public {
        doHardWork();
        // contract reserves at most 1 ton. Never throws exceptions
        tvm.rawReserve(1 ton, 0 + 2);
        msg.sender.transfer({value: 0, flag: 128}); // sends all rest balance
        // after a successful call of `reserve2` contract's balance will be less than or equal to 1 ton
    }

    function reserve3() public {
        doHardWork();
        // Contract reserves all but 1 ton from the remaining balance of the account
        // or 0 ton if remaining balance less than 1 ton.
        // Never throws exceptions.
        tvm.rawReserve(1 ton, 1 + 2);
        msg.sender.transfer({value: 0, flag: 128});
    }

    function reserve12() public {
        doHardWork();
        tvm.rawReserve(0.3 ton, 4 + 8);
        msg.sender.transfer({value: 0, flag: 128});
        // Let's consider that the contract had balance equal to 5 ton before the function `reserve4`
        // was called by an internal message with value of 0.5 ton.
        // It means that original_balance (see API.md for details) is approximately equal to 5 ton.
        // `tvm.rawReserve` will reserve 5 - 0.3 = 4.7 tons
        // Throws an exception if at the action phase there is not enough funds.
    }
}
