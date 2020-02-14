#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

// Implementation of the contract's constructor.
void constructor_Impl () {
  tvm_accept();
}

#ifndef NODE_RUN
#include "client-address-workaround.h"
#endif

void getGrams_Impl(unsigned value) {
  tvm_accept();
#ifdef NODE_RUN
  // This is how sender's address should be obtained when running on a node.
  MsgAddressInt sender = get_sender_address();
#else
  // And this is a workaround for running the test in a limited environment,
  // i.e. by means of tvm_linker test command.
  MsgAddressInt sender = { 0, 0, client_address };
#endif
  build_internal_message(&sender, value);
  send_raw_message(MSG_PAY_FEES_SEPARATELY);
}
