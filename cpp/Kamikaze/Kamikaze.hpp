#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Kamikaze interface
struct IKamikaze {
  __attribute__((external))
  void constructor() = 1;

  // Handle an external message and require tvm_accept to be called explicitly.
  __attribute__((external, noaccept))
  void selfDestruct(lazy<MsgAddressInt> addr) = 2;
};

// Kamikaze persistent data
struct DKamikaze {
  // Public key of the owner.
  uint_t<256> ownerKey;
};

// Kamikaze events
struct EKamikaze {};

}} // namespace tvm::schema
