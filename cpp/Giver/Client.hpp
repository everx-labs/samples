#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Piggybank interface
__interface IClient {
  __attribute__((internal, external))
  void constructor() = 1;

  __attribute__((external))
  void get_money(lazy<MsgAddressInt> giver, uint_t<256> balance) = 2;

  __attribute__((internal))
  uint_t<256> receive_and_report() = 3;
};

// Piggybank owner's persistent data
struct DClient {
  uint_t<1> x;
};

// Piggybank owner's events
struct EClient {};

}} // namespace tvm::schema
