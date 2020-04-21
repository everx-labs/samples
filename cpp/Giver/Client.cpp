#include <tvm/contract.hpp>
#include <tvm/contract_handle.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include "Client.hpp"
#include "Giver.hpp"
#include <tvm/msg_address.inline.hpp>

using namespace tvm::schema;
using namespace tvm;

/// Get money from giver and report the incoming value to the happy owner.
class Client final : public smart_interface<IClient>, public DClient {
public:

  /// Run on contract's deploy. Do nothing but accepts the incoming message.
  __always_inline void constructor() final;
  /// Request money from the giver contract.
  /// Get money from giver.
  /// Call method give of a giver contract deployed at address \p giver,
  /// request \p balance nanograms.
  __always_inline void get_money(lazy<MsgAddressInt> giver,
                                 uint_t<256> balance) final;
  /// Report current balance with an external message.
  /// The giver calls this method in addition to sending the requested number
  /// of grams.
  __always_inline uint_t<256> receive_and_report() final;

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body);
};
DEFINE_JSON_ABI(IClient, DClient, EClient);

// -------------------------- Public calls --------------------------------- //
void Client::constructor() {
}

void Client::get_money(lazy<MsgAddressInt> giver, uint_t<256> balance) {
  auto handle = contract_handle<IGiver>(giver);
  handle(Grams(10000000)).call<&IGiver::give>(balance);
}

uint_t<256> Client::receive_and_report() {
  return uint_t<256>(int_msg().unpack().value());
}

// Fallback function
int Client::_fallback(cell msg, slice msg_body) {
  tvm_accept();
  return 0;
}

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(Client, IClient, DClient, 1800)
