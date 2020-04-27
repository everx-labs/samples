#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Piggybank stranger's interface
struct IPiggyStranger {
  __attribute__((internal, external))
  void constructor() = 1;

  __attribute__((external))
  void deposit(lazy<MsgAddressInt> bank, uint_t<256> value) = 2;
};

// Piggybank stranger's persistent data
struct DPiggyStranger {
  // At the moment a contract implemented using smart interface has to have
  // at least one field in persistent data.
  uint_t<1> x;
};

// Piggybank stranger's events
struct EPiggyStranger {};

}} // namespace tvm::schema
