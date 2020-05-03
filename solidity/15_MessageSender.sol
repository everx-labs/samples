pragma solidity >=0.6.0;

// Contract that constructs message to call another contract function and sends it.
contract MessageSender {

	modifier alwaysAccept {
		tvm.accept();
		_;
	}

	// State variable storing the number of times 'sendMessage' function was called.
	uint counter;

	function sendMessage(address anotherContract) public alwaysAccept {
		// Create an object of TVM type Builder.
		TvmBuilder builder;

		// Construct an object of type Message X, described in spec.

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

		// Method storeUnsigned() allows to store unsigned integer of arbitrary size in the builder.
		builder.storeUnsigned(0, 1);		// int_msg_info$0
		builder.storeUnsigned(1, 1);		// ihr_disabled
		builder.storeUnsigned(1, 1);		// bounce
		builder.storeUnsigned(0, 1);		// bounced

		builder.storeUnsigned(0,2);		// src:MsgAddress we store addr_none$00
							// because network will set it for us.


		// Method store() allows to store variable of arbitrary type in the builder.
		builder.store(anotherContract); 	// dest:MsgAddressInt

		builder.storeUnsigned(0x3989680,28);	// value:CurrencyCollection : grams:Grams

		builder.storeUnsigned(0, 1);		// value:CurrencyCollection : other:ExtraCurrencyCollection
		builder.storeUnsigned(0, 4);		// ihr_fee:Grams
		builder.storeUnsigned(0, 4);		// fwd_fee:Grams
		builder.storeUnsigned(0, 64);		// created_lt:uint64   we store zero value
							// because network will set it for us.
		builder.storeUnsigned(0, 32);		// created_at:uint32   we store zero value
							// because network will set it for us.

		builder.storeUnsigned(0, 1);		// init:(Maybe (Either StateInit ^StateInit))
		builder.storeUnsigned(0, 1);		// body:(Either X ^X)

		// Filling message body
		builder.store(uint32(0x12345678));	// store functionID

		TvmBuilder builder2;
		builder2.store(address.makeAddrStd(0, 123), uint16(123), uint8(123));
		builder2.storeUnsigned(123, 11);

		TvmBuilder builder3;

		// Method storeRef() allows to store a builder in the ref of the builder.
		builder3.storeRef(builder2);

		builder.storeRef(builder3);

		// Method toCell() allows to finish builder and convert it to a cell.
		TvmCell message = builder.toCell();
		tvm.sendrawmsg(message, 1);

		// increment the counter
		counter++;
	}

	function getCounter() public view alwaysAccept returns (uint) {
		return counter;
	}
}
