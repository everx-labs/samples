pragma ton-solidity >= 0.35.0;

// Contract that constructs message to call another contract function and sends it.
contract MessageSender {

	// State variable storing the number of times 'sendMessage' function was called.
	uint public counter;

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

	function sendMessage(address anotherContract) public onlyOwnerAndAccept {
		// Create an object of TVM type Builder.
		TvmBuilder builder;

		// Construct an object of type Message X, according to the TL-B scheme
		// described in spec.

		// currencies$_ grams:Grams other:ExtraCurrencyCollection
		// = CurrencyCollection;
		//
		// int_msg_info$0 ihr_disabled:Bool bounce:Bool bounced:Bool
		// src:MsgAddress dest:MsgAddressInt
		// value:CurrencyCollection ihr_fee:Grams fwd_fee:Grams
		// created_lt:uint64 created_at:uint32 = CommonMsgInfoRelaxed;
		//
		// message$_ {X:Type} info:CommonMsgInfoRelaxed
		// init:(Maybe (Either StateInit ^StateInit))
		// body:(Either X ^X) = Message X;

		// Function storeUnsigned() allows to store unsigned integer of arbitrary size in the builder.
		builder.storeUnsigned(0, 1);		// int_msg_info$0 - constant value
		builder.storeUnsigned(1, 1);		// ihr_disabled	  - true (currently disabled for TON)
		builder.storeUnsigned(1, 1);		// bounce         - true (we want this message to bounce to the sender
											// in case of error)
		builder.storeUnsigned(0, 1);		// bounced        - false (this message is not bounced)

		builder.storeUnsigned(0, 2);		// src:MsgAddress we store addr_none$00
											// because blockchain software will replace
											// it with the current smart-contract address


		// Function store() allows to store variable of arbitrary type in the builder.
		builder.store(anotherContract); 	// dest:MsgAddressInt

		builder.storeUnsigned(0x3989680, 28);	// value:CurrencyCollection : grams:Grams   - we attach 0.01 tons to the message,
												// which is equivalent to the 10,000 gas units in the base workchain.

		builder.storeUnsigned(0, 1);		// value:CurrencyCollection : other:ExtraCurrencyCollection - we store 0, because
											// we don't attach any other currencies.

		// In the next 4 fields we store zeroes, because blockchain software will replace them
		// with the correct values after this function finishes execution.
		builder.storeUnsigned(0, 4);		// ihr_fee:Grams
		builder.storeUnsigned(0, 4);		// fwd_fee:Grams
		builder.storeUnsigned(0, 64);		// created_lt:uint64
		builder.storeUnsigned(0, 32);		// created_at:uint32


		builder.storeUnsigned(0, 1);		// init:(Maybe (Either StateInit ^StateInit)) - we store 0, because we don't attach
											// initial state of a contract.

		builder.storeUnsigned(0, 1);		// body:(Either X ^X) - we store zero, because body of the message is stored in the
											// current cell, not in the ref.

		// Filling message body
		builder.store(uint32(0x12345678));	// store functionID of the receiving contract function to process this message.

		// Attach the cell with fixed value, that will be checked in the receiving contract.
		TvmBuilder builder2;
		builder2.store(address.makeAddrStd(0, 123), uint16(123), uint8(123));
		builder2.storeUnsigned(123, 11);

		TvmBuilder builder3;

		// Function storeRef() allows to store a builder in the ref of the builder.
		builder3.storeRef(builder2);

		builder.storeRef(builder3);

		// Function toCell() allows to finish builder and convert it to a cell.
		TvmCell message = builder.toCell();
		tvm.sendrawmsg(message, 1);

		// increment the counter
		counter++;
	}
}
