pragma solidity >=0.5.0;

// Abiheader section allows to define which fields are expected to be in the header of inbound message.
// This fields have to be read in the replay protection function.
pragma AbiHeader time;
pragma AbiHeader expire;

// This contract demonstrates custom replay protection functionality.
contract CustomReplaySample {

        // State variables:
        mapping(uint => bool) messages;         // mapping to store hashes of inbound messages;
        uint value;                             // dummy variable to demonstrate contract functionality.

	// Modifier that allows public function to accept all external calls.
	modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}

        // Dummy function to demonstrate contract functionality.
        function storeValue(uint new_value) public alwaysAccept {
                value = new_value;
        }

        // Function with predefined name which is used to replace custom replay protection.
        function afterSignatureCheck(TvmSlice body, TvmCell message) private inline returns (TvmSlice) {
                // Via TvmSlice methods we read header fields from the message body
                
                body.decode(uint64); // The first 64 bits contain timestamp which is usually used to differentiate messages. 
                uint32 expireAt = body.decode(uint32);

                require(expireAt >= now, 57);   // Check that message is not expired.

                // Runtime function tvm.hash() allows to calculate the hash of the message.
                uint hash = tvm.hash(message);

                // Check that the message is unique.
                require(!messages.exists(hash), 52);

                // Save the hash of the message in  the state variable.
                messages[hash] = true;

                // At the end of the replay protection function we have to return the rest of the body slice.
                return body;
        }
}
