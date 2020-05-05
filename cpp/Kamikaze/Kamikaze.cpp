#include "Kamikaze.hpp"

#include <tvm/contract.hpp>
#include <tvm/contract_handle.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>

using namespace tvm::schema;
using namespace tvm;

/// Demonstrate how to self-destruct a deployed contract
class Kamikaze final : public smart_interface<IKamikaze>,
                       public DKamikaze {
public:
  struct error_code : tvm::error_code {
    static constexpr int wrong_owner = 101;
  };
  /// Deploy the contract and store the owner's key.
  __always_inline void constructor() final;
  /// When called by the owner self-destroy and send all outstanding balance
  /// to \p addr.
  __always_inline void selfDestruct(lazy<MsgAddressInt> addr) final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);

  // Field and methods to work with the public key of the incoming message.
  // The compiler reads the key from the incoming message and stores is in
  // pubkey_. So the key is available in a public method via tvm_pubkey().
  unsigned pubkey_ = 0;
  __always_inline void set_tvm_pubkey(unsigned pubkey) { pubkey_ = pubkey; }
  __always_inline unsigned tvm_pubkey() const { return pubkey_; }
};
DEFINE_JSON_ABI(IKamikaze, DKamikaze, EKamikaze);

// -------------------------- Public calls --------------------------------- //
void Kamikaze::constructor() { ownerKey = tvm_pubkey(); }

void Kamikaze::selfDestruct(lazy<MsgAddressInt> addr) {
  require(tvm_pubkey() == ownerKey, error_code::wrong_owner);
  tvm_accept();
  // Send outstanding balance and delete the contract from the network.
  tvm_transfer(addr, 0, false, SEND_ALL_GAS | DELETE_ME_IF_I_AM_EMPTY,
               builder().endc());
}

// Fallback function
int Kamikaze::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(Kamikaze, IKamikaze, DKamikaze, 1800)
