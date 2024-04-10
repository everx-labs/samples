pragma tvm-solidity >= 0.72.0;

// AbiHeader section allows to define which fields are expected to be in the header of inbound message.
// This fields must be read in the replay protection function.
pragma AbiHeader expire;

// This contract demonstrates custom replay protection functionality.
contract CustomReplaySample {
    struct MessageInfo {
        uint256 messageHash;
        uint32 expireAt;
    }

    // All accepted messages: expire => (messageHash => flag)
    mapping(uint32 => mapping(uint256 => bool)) messages;
    // Iteration count for cleaning mapping `messages`
    uint8 constant MAX_CLEANUP_ITERATIONS = 20;
    // Information about the last message
    MessageInfo lastMessage;
    // Dummy variable to demonstrate contract functionality.
    uint value;

    constructor() {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 104);
        tvm.accept();
    }

    // Checks condition and then a function body
    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), 104);
        _;
    }

    // Accepts the message and then calls a function body
    modifier accept {
        tvm.accept();
        _;
    }

    // Saves the message and then a function body
    modifier saveMessage {
        messages[lastMessage.expireAt][lastMessage.messageHash] = true;
        _;
    }

    // Colls a function body and then gc()
    modifier clear {
        _;
        gc();
    }

    // Function with predefined name which is used to replace custom replay protection.
    function afterSignatureCheck(TvmSlice body, TvmCell message) private inline returns (TvmSlice) {
        body.load(uint64); // The first 64 bits contain timestamp which is usually used to differentiate messages.

        // check expireAt
        uint32 expireAt = body.load(uint32);
        require(expireAt > block.timestamp, 101);   // Check whether the message is not expired.
        require(expireAt < block.timestamp + 5 minutes, 102); // Check whether expireAt is not too huge.

        // Check whether the message is not expired and then save (messageHash, expireAt) in the state variable
        uint messageHash = tvm.hash(message);
        optional(mapping(uint256 => bool)) m = messages.fetch(expireAt);
        require(!m.hasValue() || !m.get()[messageHash], 103);
        lastMessage = MessageInfo({messageHash: messageHash, expireAt: expireAt});

        // After reading message headers this function must return the rest of the body slice.
        return body;
    }

    /// Delete expired messages from `messages`.
    function gc() private {
        uint counter = 0;
        for ((uint32 expireAt, mapping(uint256 => bool) m) : messages) {
            m; // suspend compilation warning
            if (counter >= MAX_CLEANUP_ITERATIONS) {
                break;
            }
            counter++;
            if (expireAt <= block.timestamp) {
                delete messages[expireAt];
            } else {
                break;
            }
        }
    }

    // Dummy function to demonstrate contract functionality.
    // Note: execution order of the function
    //  1) calling the function `afterSignatureCheck`
    //  2) calling the modifier `onlyOwner`
    //  3) calling the modifier `accept`
    //  4) calling the modifier `saveMessage`
    //  5) calling the function (`storeValue`) body
    //  6) calling the modifier clear
    function storeValue(uint newValue) external onlyOwner accept saveMessage clear {
        value = newValue;
    }
}
