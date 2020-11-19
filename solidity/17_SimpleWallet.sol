pragma solidity >= 0.6.0;

// Simple wallet for 2 owners.
contract SimpleWallet {

    // id - sequence number of wallet that was created by `WalletProducer` contract
    uint static m_id;
    // Address of contract created this contract.
    address static m_creator;

    // Some magic number (Just as example not public variable, that calculated in constructor)
    uint m_sum;
    // pubkey of second owner
    uint256 m_secondPubkey;

    // This constructor is called by internal message
    constructor(uint n, uint256 secondPubkey) public {
        // Note: here public variables is already set.

        // Check that constructor is called by creator. It's need to check that contract is not deployd by hacker
        // which can set his constructor parameters. It's possible because public variables is used to calculate
        // address of new account, but constructor parameters - no.
        require(msg.sender == m_creator, 103);

        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);

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
        public view
        onlyOwnerAndAccept
    {
        // Perform transfer.
        destination.transfer(value, bounce, flag);
    }

    /*
     * Public Getters
     */
    // Function to get state variables.
    function getData() public view returns (uint id, address creator, uint sum) {
        return (m_id, m_creator, m_sum);
    }
}
