#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Piggybank owner's interface
struct IPiggyOwner {
  __attribute__((internal, external))
  void constructor() = 1;

  __attribute__((external))
  void deposit(lazy<MsgAddressInt> bank, uint_t<256> value) = 2;

  __attribute__((external))
  void withdraw(lazy<MsgAddressInt> bank) = 3;
};

// Piggybank owner's persistent data
struct DPiggyOwner {
  // At the moment a contract implemented using smart interface has to have
  // at least one field in persistent data.
  uint_t<1> x;
};

// Piggybank owner's events
struct EPiggyOwner {};

}} // namespace tvm::schema
