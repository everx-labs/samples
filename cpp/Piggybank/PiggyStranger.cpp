#include <tvm/contract.hpp>
#include <tvm/contract_handle.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include "PiggyStranger.hpp"
#include "Piggybank.hpp"
#include <tvm/msg_address.inline.hpp>

using namespace tvm::schema;
using namespace tvm;

class PiggyStranger final : public smart_interface<IPiggyStranger>,
                            public DPiggyStranger {
public:

  /// Deploy the contract. Do nothing aside from that.
  __always_inline void constructor() final;
  /// Call deposit method of Piggybank contract deployed at \p bank and send
  /// \p balance nanograms.
  __always_inline void deposit(lazy<MsgAddressInt> bank,
                               uint_t<256> balance) final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);
};
DEFINE_JSON_ABI(IPiggyStranger, DPiggyStranger, EPiggyStranger);

// -------------------------- Public calls --------------------------------- //
void PiggyStranger::constructor() {
}

void PiggyStranger::deposit(lazy<MsgAddressInt> bank, uint_t<256> balance) {
  contract_handle<IPiggybank>(bank)(balance.get()).call<&IPiggybank::deposit>();
}

// Fallback function
int PiggyStranger::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(PiggyStranger, IPiggyStranger,
                             DPiggyStranger, 1800)
