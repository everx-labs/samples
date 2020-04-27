#include <tvm/contract.hpp>
#include <tvm/contract_handle.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include "PiggyOwner.hpp"
#include "Piggybank.hpp"
#include <tvm/msg_address.inline.hpp>

using namespace tvm::schema;
using namespace tvm;

/// The contract which owns a piggybank. It can both deposit money to and
/// them from the bank.
class PiggyOwner final : public smart_interface<IPiggyOwner>,
                         public DPiggyOwner {
public:

  /// Deploy the contract, do nothing aside from that.
  __always_inline void constructor() final;
  /// Asynchroniously call deposit method of Piggybank contract deployed
  /// at \p bank, send \p balance nanograms to it.
  __always_inline void deposit(lazy<MsgAddressInt> bank,
                               uint_t<256> balance) final;
  /// Asynchroniously call withdraw method of Piggybank contract deployed
  /// at \p bank.
  __always_inline void withdraw(lazy<MsgAddressInt> bank) final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);
};
DEFINE_JSON_ABI(IPiggyOwner, DPiggyOwner, EPiggyOwner);

// -------------------------- Public calls --------------------------------- //
void PiggyOwner::constructor() {
}

void PiggyOwner::deposit(lazy<MsgAddressInt> bank, uint_t<256> balance) {
  contract_handle<IPiggybank>(bank)(balance.get()).call<&IPiggybank::deposit>();
}

void PiggyOwner::withdraw(lazy<MsgAddressInt> bank) {
  contract_handle<IPiggybank>(bank)().call<&IPiggybank::withdraw>();
}

// Fallback function
int PiggyOwner::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(PiggyOwner, IPiggyOwner, DPiggyOwner, 1800)
