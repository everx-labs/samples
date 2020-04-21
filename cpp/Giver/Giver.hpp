#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Piggybank interface
struct IGiver {
  __attribute__((internal, external))
  void constructor() = 1;

  __attribute__((internal))
  void give(uint_t<256> value) = 2;
};

// Giver persistent data
struct DGiver {
  // At the moment contract's persistend data has to have at least one field.
  uint_t<1> x;
};

// Giver events
struct EGiver {};

}} // namespace tvm::schema
