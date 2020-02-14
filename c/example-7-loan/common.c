#include "common.h"

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
#include "ton-sdk/define-ton-struct-c.inc"

#undef TON_STRUCT_NAME
#undef TON_STRUCT

void send_message(MsgAddressInt dest, unsigned rpaddr, unsigned value) {
  const unsigned fee = 10000000;
  Grams val_grams;
  val_grams.amount.len = tonstdlib_ubytesize(fee);
  val_grams.amount.value = fee;

  CurrencyCollection val;
  val.grams = val_grams;
  val.other = 0;

  Grams zero_grams;
  zero_grams.amount.len = 0;
  zero_grams.amount.value = 0;

  Message_uint64 msg;
  msg.ihr_disabled = 0;
  msg.bounce = 0;
  msg.bounced = 0;
  msg.src = dest;
  msg.dst = dest;
  msg.val = val;
  msg.ihr_fee = zero_grams;
  msg.fwd_fee = zero_grams;
  msg.created_lt = 0;
  msg.created_at = 0;

  msg.init = 0;
  msg.body = 0;
  msg.rpaddr = rpaddr;
  msg.value = value;

  Serialize_Message_uint64(&msg);
  send_raw_message(MSG_NO_FLAGS);
}
