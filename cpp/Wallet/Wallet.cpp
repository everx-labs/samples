#include "Wallet.hpp"
#include <tvm/contract.hpp>
#include <tvm/msg_address.inline.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include <tvm/smart_switcher.hpp>

using namespace tvm::schema;
using namespace tvm;

class Wallet final : public smart_interface<IWallet>, public DWallet {
public:
  struct error_code : tvm::error_code {
    static constexpr int wrong_owner = 101;
    static constexpr int not_enough_balance = 102;
  };

  // Public methods
  __always_inline void constructor() final;
  __always_inline void set_subscription_account(MsgAddressInt addr) final;
  __always_inline MsgAddressInt get_subscription_account() final;
  __always_inline void send_transaction(MsgAddressInt dest, uint_t<128> value,
                                        bool_t bounce) final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);

  // Field and methods to work with the public key of the incoming message.
  // The compiler reads the key from the incoming message and stores is in
  // pubkey_. So the key is available in a public method via tvm_pubkey().
  unsigned pubkey_ = 0;
  __always_inline void set_tvm_pubkey(unsigned pubkey) { pubkey_ = pubkey; }
  __always_inline unsigned tvm_pubkey() const { return pubkey_; }
};

// ABI file generating macro.
// To generate ABI run clang with -export-json-abi argument
DEFINE_JSON_ABI(IWallet, DWallet, EWallet);

// -------------------------- Public calls --------------------------------- //
/// Store owner's key.
// Note that signature checking is auto-generated.
void Wallet::constructor() { ownerKey = tvm_pubkey(); }

/// Allow \p addr to request \p send_transacton.
void Wallet::set_subscription_account(MsgAddressInt addr) {
  require(tvm_pubkey() == ownerKey, error_code::wrong_owner);
  subscriber = addr;
}

MsgAddressInt Wallet::get_subscription_account() { return subscriber; }

/// Send \p value grams to \p dest.
void Wallet::send_transaction(MsgAddressInt dest, uint_t<128> value,
                              bool_t bounce) {
  require(tvm_pubkey() == ownerKey ||
              int_msg().unpack().int_sender()() == subscriber,
          error_code::wrong_owner);

  int balance = smart_contract_info::balance_remaining();
  require(value.get() > 0 && value.get() < balance,
          error_code::not_enough_balance);

  tvm_transfer(dest, value.get(), bounce.get());
}

/// Fallback function which is called when function id is not parsed or wrong.
int Wallet::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
// Main entry function are auto generated.
DEFAULT_MAIN_ENTRY_FUNCTIONS(Wallet, IWallet, DWallet,
                             1800 /* interval for timestamp replay protection
                                     in seconds */)
