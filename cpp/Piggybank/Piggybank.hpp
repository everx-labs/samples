#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Piggybank interface
__interface IPiggybank {
  __attribute__((internal, external))
  void constructor(lazy<MsgAddress> owner, uint_t<256> limit) = 1;

  __attribute__((internal))
  void deposit() = 2;

  __attribute__((internal))
  void withdraw() = 3;
};

// Piggybank persistent data
struct DPiggybank {
  lazy<MsgAddress> owner;
  uint_t<256> limit;
  uint_t<256> balance;
};

}} // namespace tvm::schema

