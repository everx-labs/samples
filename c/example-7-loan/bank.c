#include "common.h"

// Declaring client's remote method
extern void get_credit_callback(int);
void get_credit_callback_Impl(int balance) { }

__tvm_cell map_persistent;

void constructor_Impl() {
  ACCEPT();

  // Construct empty dict
  map_persistent = __builtin_tvm_endc(__builtin_tvm_stdict(
    __builtin_tvm_newdict(), __builtin_tvm_newc()));
}

void set_allowance_Impl(MsgAddressInt addr, int amount) {
  ACCEPT();

  // Wrap amount into slice s
  __tvm_builder b = __builtin_tvm_newc();
  b = __builtin_tvm_sti(amount, b, 64);
  __tvm_cell c = __builtin_tvm_endc(b);
  __tvm_slice s = __builtin_tvm_ctos(c);

  // Load dict d from persistent memory
  __tvm_cell d = __builtin_tvm_plddict(__builtin_tvm_ctos(map_persistent));
  // Update it with (addr -> s) pair
  d = __builtin_tvm_dictuset(s, addr.address, d, 256);
  // Store dict back
  map_persistent =
    __builtin_tvm_endc(__builtin_tvm_stdict(d, __builtin_tvm_newc()));
}

TVM_CUSTOM_EXCEPTION(INVALID_ADDRESS, 101);

void get_credit_Impl() {
  ACCEPT();

  MsgAddressInt sender = get_sender_address();
  tvm_assert(sender.anycast == 0, INVALID_ADDRESS);
  tvm_assert(sender.workchain_id == 0, INVALID_ADDRESS);

  // Load dict d from persistent memory
  __tvm_cell d = __builtin_tvm_plddict(__builtin_tvm_ctos(map_persistent));

  // Try getting value by the address key
  struct __attribute__((tvm_tuple)) { __tvm_slice s; int found; } st =
    __builtin_tvm_dictuget(sender.address, d, 256);
  // Bail out if key doesn't exist
  tvm_assert(st.found, INVALID_ADDRESS);

  // Unwrap amount
  int amount = __builtin_tvm_pldu(st.s, 64);

  send_message(sender, (unsigned)get_credit_callback, amount);
}
