#include <tvm/contract.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include "Piggybank.hpp"
#include <tvm/msg_address.inline.hpp>

using namespace tvm::schema;
using namespace tvm;

/// A contract which receives money from other contracts, and once the limit is
/// reached a dedicated contract called the piggy bank owner is able to withdraw
/// the savings.
class Piggybank final : public smart_interface<IPiggybank>, public DPiggybank {
public:
  struct error_code : tvm::error_code {
    static constexpr int wrong_owner = 101;
    static constexpr int not_enough_balance = 102;
  };

  /// Deploy the contract and store \p pb_owner and \p pb_limit in
  /// persistent memory.
  __always_inline void constructor(lazy<MsgAddress> pb_owner,
                                   uint_t<256> pb_limit) final;
  /// When other contract calls deposit, the money it attached to the message
  /// count towards the limit.
  __always_inline void deposit() final;
  /// If called by the owner and savings exceeded the limit, send them
  /// to the caller.
  __always_inline void withdraw() final;
  /// Auxiliary method to get current amount of savings.
  __always_inline uint_t<256> get_balance() final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);
};
DEFINE_JSON_ABI(IPiggybank, DPiggybank, EPiggybank);

// -------------------------- Public calls --------------------------------- //
void Piggybank::constructor(lazy<MsgAddress> pb_owner, uint_t<256> pb_limit) {
  owner = pb_owner;
  limit = pb_limit;
  balance = 0;
}

void Piggybank::deposit() {
  balance += int_msg().unpack().value();
}

void Piggybank::withdraw() {
  auto sender = int_msg().unpack().int_sender();

  require(sender.raw_slice() == owner.raw_slice(), error_code::wrong_owner);
  require(balance >= limit, error_code::not_enough_balance);

  tvm_transfer(sender, balance.get(), false);
  balance = 0;
}

uint_t<256> Piggybank::get_balance() {
  return balance;
}

// Fallback function
int Piggybank::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(Piggybank, IPiggybank, DPiggybank, 1800)
