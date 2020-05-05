#include "HelloWorld.hpp"

#include <tvm/contract.hpp>
#include <tvm/smart_switcher.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>

using namespace tvm::schema;
using namespace tvm;

class HelloWorld final : public smart_interface<IHelloWorld>,
                         public DHelloWorld {
public:
  /// Deploy the contract.
  __always_inline void constructor() final {}
  __always_inline uint_t<8> hello_world() final {return uint_t<8>(42);};

  // Function is called in case of unparsed or unsupported func_id
  static __always_inline int _fallback(cell msg, slice msg_body) { return 0; };
};
DEFINE_JSON_ABI(IHelloWorld, DHelloWorld, EHelloWorld);

// ----------------------------- Main entry functions ---------------------- //
DEFAULT_MAIN_ENTRY_FUNCTIONS(HelloWorld, IHelloWorld, DHelloWorld, 1800)
