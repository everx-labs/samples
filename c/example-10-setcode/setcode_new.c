#include <ton-sdk/tvm.h>

volatile int timestamp_persistent;

void constructor_Impl() {
  tvm_assert(timestamp_persistent == 0, 100);
  __builtin_tvm_accept();
  timestamp_persistent = __builtin_tvm_getglobal(12);
}

void default_replay_protect() {
  int timestamp = __builtin_tvm_getglobal(12);
  tvm_assert(timestamp_persistent < timestamp, 101);
  __builtin_tvm_accept();
  timestamp_persistent = timestamp;
}

int run_Impl() {
  default_replay_protect();
  return 0xfeedc0de;
}

void setcode_Impl(__tvm_cell c) {
  default_replay_protect();
  __builtin_tvm_setcode(c);
}
