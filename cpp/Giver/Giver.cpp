#include <tvm/contract.hpp>
#include <tvm/contract_handle.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include "Giver.hpp"
#include "Client.hpp"
#include <tvm/msg_address.inline.hpp>

using namespace tvm::schema;
using namespace tvm;

/// Gives money to everyone in need.
class Giver final : public smart_interface<IGiver>, public DGiver {
public:
  struct error_code : tvm::error_code {
    static constexpr int not_enough_balance = 101;
  };

  __always_inline void constructor() final;
  __always_inline void give(uint_t<256> value) final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);
};
DEFINE_JSON_ABI(IGiver, DGiver, EGiver);

// -------------------------- Public calls --------------------------------- //
void Giver::constructor() {
}

void Giver::give(uint_t<256> value) {
  auto sender = int_msg().unpack().int_sender();
  auto handle = contract_handle<IClient>(sender);
  handle(Grams(value.get())).call<&IClient::receive_and_report>();
}

// Fallback function
int Giver::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(Giver, IGiver, DGiver, 1800)
