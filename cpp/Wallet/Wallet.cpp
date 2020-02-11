#include <tvm/parser.hpp>
#include <tvm/builder.hpp>
#include <tvm/schema/make_builder.hpp>
#include <tvm/schema/make_parser.hpp>
#include <tvm/schema/message.hpp>
#include <tvm/schema/abiv1.hpp>
#include <tvm/smart_contract_info.hpp>
#include <tvm/signature_checker.hpp>
#include <tvm/dictionary.hpp>
#include <tvm/smart_contract_info.hpp>
#include <tvm/replay_attack_protection/timestamp.hpp>
#include <tvm/contract.hpp>

using namespace tvm::schema;
using namespace tvm;

class Wallet : public tvm::contract {
public:
  enum class error_code : unsigned {
    replay_attack_check            = 100,
    bad_signature                  = 101,
    no_requested_persistent        = 102,
    wrong_owner                    = 103,
    wrong_public_call              = 104,
    unsupported_call_method        = 105,
    bad_arguments                  = 106,
    bad_incoming_msg               = 107,
    invalid_transfer_value         = 108,
  };
  enum class function_hashes : unsigned {
    init = 0x00000001,
    set_subscription_account = 0x00000002,
    get_subscription_account = 0x00000003,
    send_transaction = 0x00000004
  };
  using replay_protection = replay_attack_protection::timestamp<100>;

  static persistent<-1, uint256_t> owner;
  static persistent<-2, MsgAddress> subscription;
  static persistent<-3, replay_protection::persistent_t> timestamp;

  static int init(cell msg, slice msg_body);
  static int set_subscription_account(cell msg, slice msg_body);
  static int get_subscription_account(cell msg, slice msg_body);
  static int send_transaction(cell msg, slice msg_body);

  inline static unsigned err(Wallet::error_code v) { return static_cast<unsigned>(v); }
private:
  static void replay_protection_check(unsigned msg_timestamp) {
    auto v = replay_protection::check(msg_timestamp, timestamp);
    assert(!!v, err(error_code::replay_attack_check));
    timestamp = *v;
  }
};

int Wallet::init(cell msg, slice msg_body) {
  unsigned sender_key = check_signature(msg_body, err(error_code::bad_signature));
  assert(!owner.initialized(), err(error_code::wrong_owner));
  accept();

  owner = sender_key;
  subscription = MsgAddress{MsgAddressExt{addr_none{}}};
  timestamp = replay_protection::init();
  return 111;
}

// For subscription contract
int Wallet::set_subscription_account(cell msg, slice msg_body) {
  struct args_t {
    abiv1::external_inbound_msg_header hdr;
    MsgAddress address;
  };
  unsigned sender_key = check_signature(msg_body, err(error_code::bad_signature));

  unsigned owner_v = owner.get();
  assert(owner_v == sender_key, err(error_code::wrong_owner));

  auto args = parse_args<args_t>(msg_body, err(error_code::bad_arguments));
  replay_protection_check(args.hdr.timestamp);
  accept();

  subscription = args.address;
  return 222;
}

int Wallet::get_subscription_account(cell msg, slice msg_body) {
  using args_t = abiv1::external_inbound_msg_header;
  struct return_t {
    abiv1::external_outbound_msg_header hdr;
    MsgAddress subscription;
  };

  unsigned sender_key = check_signature(msg_body, err(error_code::bad_signature));

  MsgAddress subscription_v = subscription.get();
  auto args = parse_args<args_t>(msg_body, err(error_code::bad_arguments));
  replay_protection_check(args.timestamp);
  accept();

  return_t result;
  result.hdr.function_id = abiv1::answer_id(args.function_id());
  result.subscription = subscription_v;

  MsgAddressExt answer_dst = get_incoming_ext_src(msg);

  ext_out_msg_info_relaxed out_info;
  out_info.src = addr_none{};
  out_info.dest = answer_dst;
  out_info.created_lt = 0;
  out_info.created_at = 0;

  message_relaxed<return_t> out_msg;
  out_msg.info = out_info;
  out_msg.body = result;

  sendmsg(build(out_msg).endc(), 0);
  return 333;
}

// Allows to transfer grams to destination account.
int Wallet::send_transaction(cell msg, slice msg_body) {
  struct args_t {
    abiv1::external_inbound_msg_header hdr;
    MsgAddressInt dest;  // Transfer target address.
    uint_t<128> value; // Nanograms value to transfer.
    bool_t bounce;
  };

  args_t args = parse_args<args_t>(msg_body, err(error_code::bad_arguments));
  replay_protection_check(args.hdr.timestamp);

  unsigned sender_key = check_signature(msg_body, err(error_code::bad_signature));
  unsigned owner_v = owner.get();
  MsgAddress subscription_v = subscription.get();

  MsgAddressExt sender = get_incoming_ext_src(msg);

  bool has_subscription = subscription_v != MsgAddress{MsgAddressExt{addr_none{}}};
  assert(sender_key == owner_v ||
          (has_subscription && MsgAddress(sender) == subscription_v),
          err(error_code::wrong_owner));

  accept();

  int balance = smart_contract_info::balance_remaining();
  assert(args.value() > 0 && args.value() < balance, err(error_code::invalid_transfer_value));

  tvm_transfer(args.dest, args.value, args.bounce);
  return 444;
}

__attribute__((tvm_raw_func)) int main_external(__tvm_cell msg, __tvm_slice msg_body) {
  cell msg_v(msg);
  slice msg_body_v(msg_body);

  parser msg_parser(msg_body_v);

  auto func_id = msg_parser.ldu(32);
  switch (static_cast<Wallet::function_hashes>(func_id)) {
  case Wallet::function_hashes::init:
    return Wallet::init(msg_v, msg_body_v);
  case Wallet::function_hashes::set_subscription_account:
    return Wallet::set_subscription_account(msg_v, msg_body_v);
  case Wallet::function_hashes::get_subscription_account:
    return Wallet::get_subscription_account(msg_v, msg_body_v);
  case Wallet::function_hashes::send_transaction:
    return Wallet::send_transaction(msg_v, msg_body_v);
  }
  Wallet::tvm_throw(Wallet::err(Wallet::error_code::wrong_public_call));
  return 0;
}

__attribute__((tvm_raw_func)) int main_internal(__tvm_cell msg, __tvm_slice msg_body) {
  Wallet::tvm_throw(Wallet::err(Wallet::error_code::unsupported_call_method));
  return 0;
}

__attribute__((tvm_raw_func)) int main_ticktock(__tvm_cell msg, __tvm_slice msg_body) {
  Wallet::tvm_throw(Wallet::err(Wallet::error_code::unsupported_call_method));
  return 0;
}

__attribute__((tvm_raw_func)) int main_split(__tvm_cell msg, __tvm_slice msg_body) {
  Wallet::tvm_throw(Wallet::err(Wallet::error_code::unsupported_call_method));
  return 0;
}

__attribute__((tvm_raw_func)) int main_merge(__tvm_cell msg, __tvm_slice msg_body) {
  Wallet::tvm_throw(Wallet::err(Wallet::error_code::unsupported_call_method));
  return 0;
}
