#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

#include "client.h"

#define TON_STRUCT_NAME Message_uint64
#define TON_STRUCT \
    FIELD_UNSIGNED(rpaddr, 32) \
    FIELD_UNSIGNED(value, 64)
#include "ton-sdk/define-ton-struct-header.inc"
#define TON_STRUCT_NAME Message_uint64
#define TON_STRUCT \
    FIELD_UNSIGNED(rpaddr, 32) \
    FIELD_UNSIGNED(value, 64)
#include "ton-sdk/define-ton-struct-c.inc"

void getGrams();
void getGrams_Impl(unsigned value) {}

void build_internal_uint64_message (MsgAddressInt* dest, unsigned data) {
    build_internal_message_bounce(dest, 0, 0);
    Message_uint64 msg = {(unsigned) &getGrams, data};
    __tvm_builder builder = __builtin_tvm_cast_to_builder(__builtin_tvm_getglobal(6));
    Serialize_Message_uint64_Impl(&builder, &msg);
    __builtin_tvm_setglobal(6, __builtin_tvm_cast_from_builder(builder));
}

// Number of remote procedure calls.
int numCalls_persistent;

// Implementation of the contract's constructor.
void constructor_Impl () {
  tvm_accept();
}

void requestGrams_Impl(MsgAddressInt remoteContractAddr, unsigned value) {
  tvm_accept();
  // increment the counter
  numCalls_persistent++;
  // call remote contract function with parameter
  build_internal_uint64_message (&remoteContractAddr, value);
  send_raw_message (MSG_PAY_FEES_SEPARATELY);
}
