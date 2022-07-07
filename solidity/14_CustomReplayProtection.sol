pragma ever-solidity >= 0.35.0;

// AbiHeader section allows to define which fields are expected to be in the header of inbound message.
// This fields must be read in the replay protection function.
pragma AbiHeader time;
pragma AbiHeader expire;

// This contract demonstrates custom replay protection functionality.
contract CustomReplaySample {
    // Each transaction is limited by gas, so we must limit count of iteration in loop.
    uint8 constant MAX_CLEANUP_MSGS = 30;

    // mapping to store hashes of inbound messages;
    mapping(uint => uint32) messages;
    // dummy variable to demonstrate contract functionality.
    uint public value;

    constructor() public {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    // Dummy function to demonstrate contract functionality.
    function storeValue(uint new_value) public onlyOwnerAndAccept {
        // Let's clear expired messages from dict
        gc();

        value = new_value;
    }

    // Function with predefined name which is used to replace custom replay protection.
    function afterSignatureCheck(TvmSlice body, TvmCell message) private inline returns (TvmSlice) {
        body.decode(uint64); // The first 64 bits contain timestamp which is usually used to differentiate messages.
        uint32 expireAt = body.decode(uint32);

        require(expireAt > now, 101);   // Check that message is not expired.

        // Runtime function tvm.hash() allows to calculate the hash of the message.
        uint hash = tvm.hash(message);
        // Check that the message is unique.
        require(!messages.exists(hash), 102);
        // Save the hash of the message in  the state variable.
        messages[hash] = expireAt;

        // After reading message headers this function must return the rest of the body slice.
        return body;
    }

    /// @notice Allows to delete expired messages from dict.
    function gc() private {
        uint counter = 0;
        for ((uint256 msgHash, uint32 expireAt) : messages) {
            if (counter >= MAX_CLEANUP_MSGS) {
                break;
            }
            counter++;
            if (expireAt <= now) {
                delete messages[msgHash];
            }
        }
    }
}
