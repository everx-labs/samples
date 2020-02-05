#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

unsigned value_persistent = 0;
unsigned caller_persistent = 77;

// Implementation of the contract's constructor.
void constructor_Impl () {
  ACCEPT();
}

void remoteProcedure_Impl(unsigned value) {
  ACCEPT();
  value_persistent = value;
  caller_persistent = get_sender_address().address;
}

unsigned getValue_Impl() {
  ACCEPT();
  return value_persistent;
}

unsigned getCaller_Impl() {
  ACCEPT();
  return caller_persistent;
}
