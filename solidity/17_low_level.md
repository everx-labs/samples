## Constructor message structure

All messages in TON have type **Message X**. Spec describes this type with this TL-B scheme:

```TL-B
message$_ {X:Type} info:CommonMsgInfo
init:(Maybe (Either StateInit ^StateInit))
body:(Either X ^X) = Message X;
```

CommonMsgInfo structure has 3 types:

* Internal message info;
* External inbound message info;
* External outbound message info.

To deploy a new contract from the contract we need to send an internal message. TL-B scheme for CommonMsgInfo of an internal message:

```TL-B
int_msg_info$0 ihr_disabled:Bool bounce:Bool src:MsgAddressInt dest:MsgAddressInt
value:CurrencyCollection ihr_fee:Grams fwd_fee:Grams created_lt:uint64
created_at:uint32 = CommonMsgInfo;
```

CommonMsgInfo contains structures, that are described by the following TL-B schemes:

```TL-B
nothing$0 {X:Type} = Maybe X;
just$1 {X:Type} value:X = Maybe X;
left$0 {X:Type} {Y:Type} value:X = Either X Y;
right$1 {X:Type} {Y:Type} value:Y = Either X Y;

anycast_info$_ depth:(## 5) rewrite_pfx:(depth * Bit) = Anycast;

addr_none$00 = MsgAddressExt;

addr_std$10 anycast:(Maybe Anycast)
workchain_id:int8 address:uint256 = MsgAddressInt;

var_uint$_ {n:#} len:(#< n) value:(uint (len * 8))
= VarUInteger n;
nanograms$_ amount:(VarUInteger 16) = Grams;

extra_currencies$_ dict:(HashmapE 32 (VarUInteger 32))
= ExtraCurrencyCollection;
currencies$_ grams:Grams other:ExtraCurrencyCollection
= CurrencyCollection;
```

When we deploy a contract we need to attach a stateInit of that contract, but we use tvm_linker to obtain it, that's why we don't need to construct it.

In case of deployment via **new** we also pass arguments to the constructor of the contract. That's why we need to attach constructor call as the body of the message. To do it we need to store **constructor** function identifier and encode it's parameters.

In binary form the whole constructor message look like this:

```TVM_Message
---CommonMsgInfo---
0                   - int_msg_info$0 - constant value
1                   - ihr_disabled - true (currently disabled for TON)
1                   - bounce - true (we want this message to bounce to the sender in case of error)
0                   - bounced - false (this message is not bounced)

00                  - src:MsgAddress we store addr_none$00 because blockchain software will replace
                      it with the current smart-contract address

                    - dest:MsgAddressInt:
10                  - addr_std$10 - constant value
00000000            - workchain_id:int8 - store zero
hash(stateInit)     - address:uint256 - address of the contract is equal to hash of the stateInit

                    - value:CurrencyCollection: (for example we will store 10_000_000 nanograms)
                    - grams:Grams
0011                - len (because 10_000_000 < 2^(3*8))
x989680             - value (3*8 bits)
0                   - other:ExtraCurrencyCollection  (we don't attach any other currencies)

                    - In the next 4 fields we store zeroes, because blockchain software will replace them
                      with the correct values after this function finishes execution.
0000                - ihr_fee:Grams
0000                - fwd_fee:Grams
x0000000000000000   - created_lt:uint64
x00000000           - created_at:uint32
------------------

---stateInit---
1                   - Maybe - 1 because we attach a stateInit
1                   - Either StateInit ^StateInit - 1 because we store stateInit in a ref
                    - Store stateInit in a ref of
---------------

---body---
0/1                 - Maybe: 0 if store body in current cell, otherwise 1
constructorID       - uint32 constructor identifier value
<encoded constructor params>
----------
```
