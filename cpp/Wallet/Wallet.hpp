#pragma once

#include <tvm/schema/message.hpp>

namespace tvm { namespace schema {

// Wallet interface
// It supposed to be passed as an argument to smart_interface template class.
// The compiler auto generates essential logic for each public method of
// the class and the class is supposed to be an interface (i.e. has only
// pure virtual public methods and no data).
//  - incoming message parsing and extracting arguments.
//  - return value serializing and sending via an external message.
//  - timestamp-based replay protection check.
//  - signature checking (for an external call).
//  - accepting a message.
struct IWallet {
  __attribute__((external)) // Only awailable from an offchain application.
  void constructor() = 1 /* Function ID */;

  __attribute__((external)) // Only awailable from an offchain application.
  void set_subscription_account(MsgAddressInt addr) = 2;

  __attribute__((getter))   // Supposed to be run locally for free.
  MsgAddressInt get_subscription_account() = 3;

  __attribute__((internal, external))
  // Available both from a contract and from an off-chain application.
  void send_transaction(MsgAddressInt dest,
                        uint_t<128> value,
                        bool_t bounce) = 4;
};

// Wallet persistent data
struct DWallet {
  uint256 ownerKey;         // owner's key
  MsgAddressInt subscriber; // trusted contract address
  // timestamp for replay protection is auto-generated
};

// Wallet events
struct EWallet {};

}} // namespace tvm::schema
