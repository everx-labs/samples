#include "common.h"

// Declaring bank's remote method
extern void get_credit();
void get_credit_Impl() { }

volatile int credit_persistent;

void constructor_Impl() {
  ACCEPT();
}

// A client calls this method,
void get_my_credit_Impl(MsgAddressInt bank) {
  ACCEPT();
  send_message(bank, (unsigned)get_credit, 0);
}

// and a bank calls this one in response.
void get_credit_callback_Impl(unsigned balance) {
  ACCEPT();
  credit_persistent = balance;
}
