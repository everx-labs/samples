#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

#define TON_STRUCT_NAME Message_uint64
#define TON_STRUCT \
  FIELD_CONSTANT_UNSIGNED(zero, 0, 1) \
  FIELD_UNSIGNED(ihr_disabled, 1) \
  FIELD_UNSIGNED(bounce, 1) \
  FIELD_UNSIGNED(bounced, 1) \
  FIELD_COMPLEX(src, MsgAddressInt) \
  FIELD_COMPLEX(dst, MsgAddressInt) \
  FIELD_COMPLEX(val, CurrencyCollection) \
  FIELD_COMPLEX(ihr_fee, Grams) \
  FIELD_COMPLEX(fwd_fee, Grams) \
  FIELD_UNSIGNED(created_lt, 64) \
  FIELD_UNSIGNED(created_at, 32) \
  FIELD_UNSIGNED(init, 1) \
  FIELD_UNSIGNED(body, 1) \
  FIELD_UNSIGNED(rpaddr, 32) \
  FIELD_UNSIGNED(value, 64)
#include "ton-sdk/define-ton-struct-header.inc"

#undef TON_STUCT_NAME
#undef TON_STRUCT

void send_message(MsgAddressInt dest, unsigned rpaddr, unsigned value);
