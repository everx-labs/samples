#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Hello world interface
struct IHelloWorld {
  // Handle external messages only
  __attribute__((external))
  void constructor() = 1;

  // Handle external messages only
  __attribute__((external, noaccept))
  uint_t<8> hello_world() = 2;
};

// Hello world persistent data
struct DHelloWorld {
  uint_t<256> ownerKey;
};

// Hello world events
struct EHelloWorld {};

}} // namespace tvm::schema
