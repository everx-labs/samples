#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

unsigned owner_persistent = 0;

TVM_CUSTOM_EXCEPTION (MESSAGE_SENDER_NOT_OWNER, 100);
TVM_CUSTOM_EXCEPTION (LIMIT_IS_OVERRUN, 101);
TVM_CUSTOM_EXCEPTION (INVALID_TRANSFER_VALUE, 102);
TVM_CUSTOM_EXCEPTION (DESTINATION_ADDRESS_ZERO, 103);
TVM_CUSTOM_EXCEPTION (MESSAGE_MUST_BE_SIGNED, 104);
TVM_CUSTOM_EXCEPTION (ALREADY_INITIALIZED, 105);

void constructor_Impl () {
    ACCEPT();
    unsigned owner = tvm_sender_pubkey ();
    tvm_assert (owner != 0, MESSAGE_MUST_BE_SIGNED);
    tvm_assert (owner_persistent == 0, ALREADY_INITIALIZED);
    owner_persistent = owner;
}

void sendTransaction_Impl (unsigned dest, unsigned value, unsigned bounce) {
    ACCEPT();

    SmartContractInfo sc_info = get_SmartContractInfo();
    int balance = sc_info.balance_remaining.grams.amount.value;
    tvm_assert (value > 0 && value < balance, INVALID_TRANSFER_VALUE);

    tvm_assert (tvm_sender_pubkey() != 0, MESSAGE_MUST_BE_SIGNED);
    tvm_assert (tvm_sender_pubkey() == owner_persistent, MESSAGE_SENDER_NOT_OWNER);
    tvm_assert (dest != 0, DESTINATION_ADDRESS_ZERO);

    MsgAddressInt destination = build_msg_address_int (0, dest);
    build_internal_message_bounce (&destination, value, bounce);
    send_raw_message (0);
}
