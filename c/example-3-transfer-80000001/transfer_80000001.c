#include "transfer_80000001.h"
#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"

void transfer_Impl () {
    ACCEPT();

    // MsgAddressInt structure corresponds to the structure from TON
    // blockchain document.
    MsgAddressInt dest;

    // Anycast messages are not supported in current C SDK, so specify 0 in
    // this field.
    dest.anycast = 0;

    // We work with workchain 0.
    dest.workchain_id = 0;

    // Destination address: unsigned ints in TVM are 256-bits, so a contract
    // address easily fits into unsigned.
    dest.address = 0x80000001;

    // Call library function that builds an empty internal message (internal
    // message with empty payload). Note that the MsgAddressInt structure is
    // passed by pointer. The message is built in a work slice stored
    // deep in the standard library. You cannot work with its value directly,
    // but you can serialize values to it and deserialize values from it.
    //
    // The build_internal_message function in its turn empties the work slice,
    // and then performs several serializations, thus preparing an internal
    // message.
    build_internal_message (&dest, 0xAAAA);

    // Call library function that sends a message generated in a work slice.
    // The function argument is sending flag.
    send_raw_message (1);
}

void constructor_Impl () {
    ACCEPT();
}
