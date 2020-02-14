#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

unsigned value_persistent = 0;
unsigned caller_persistent = 77;

// Implementation of the contract's constructor.
void constructor_Impl () {
  tvm_accept();
}

void remoteProcedure_Impl(unsigned value) {
  tvm_accept();
  value_persistent = value;
  caller_persistent = get_sender_address().address;
}

unsigned getValue_Impl() {
  tvm_accept();
  return value_persistent;
}

unsigned getCaller_Impl() {
  tvm_accept();
  return caller_persistent;
}
