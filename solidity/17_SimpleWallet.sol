pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

// Simple wallet for 2 owners.
contract SimpleWallet {

    // Some magic number (Just example of a non static variable, that is calculated in the constructor)
    uint public m_sum;
    // pubkey of second owner
    uint256 m_secondPubkey;

    /*
     * static variables
     */
    // id - sequence number of wallet that was created by `WalletProducer` contract
    uint static public m_id;
    // Address of contract created this contract.
    address static public m_creator;


    // This constructor is called by internal message
    constructor(uint n, uint256 secondPubkey) public {
        // Note: here static variables are already set.

        // Check that constructor is called by creator. It's need to check that contract is not deployd by hacker
        // which can set his constructor parameters. It's possible because public variables is used to calculate
        // address of new account, but constructor parameters - no.
        require(msg.sender == m_creator, 103);

        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // check that second public key is set
        require(secondPubkey != 0, 102);

        for (uint i = 0; i < n; ++i) {
            m_sum += i;
        }

        // It's good idea to mark 'm_secondPubkey' as public variable. But for example it's not public.
        m_secondPubkey = secondPubkey;
    }

    modifier onlyOwnerAndAccept {
        // Check that the function was called by some owner by external message and this message is signed.
        require(
            msg.pubkey() == tvm.pubkey() || // check that message is signed by first owner
            msg.pubkey() == m_secondPubkey  // check that message is signed by second owner
        );
        tvm.accept();
        _;
    }

    // Function to make an arbitrary transfer. Called by external message
    function sendTransaction(address destination, uint128 value, bool bounce, uint8 flag)
        public pure
        onlyOwnerAndAccept
    {
        // Perform transfer.
        destination.transfer(value, bounce, flag);
    }
}
