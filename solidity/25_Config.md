# Function arguments specification

Sometimes it can be not obvious in which way function arguments should be specified,
especially if it is a large structure with different and complex fields. 
It is generally described in [abi doc](https://github.com/tonlabs/ton-labs-abi/blob/master/docs/ABI_2.1_spec.md).
And this example was made to help users clear this moment.


To deploy this sample contract user should call tonos-cli command with such example parameters:

```bash
$ tonos-cli deploy  --sign keys/key0 --wc 0 --abi 25_Config.abi.json 25_Config.tvc '{
            "initial_config":{
                 "_bool":true,
                 "_i256":1,
                "_u256":2,
                "_u8":3,
                "_i16":4,
                "_i7":5,
                "_u53":6,
                "dest":"0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
                "cell":"te6ccgEBAQEAAgAAAA==",
                "map":{"0":"0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","1":"0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdee"}
            }
        }'
```

And the same way to call function:

```bash
$ tonos-cli -j call --sign keys/key0 --abi 25_Config.abi.json 0:08ce0221bce8fd710225470610ccaec8617aff7fb074b76edb51f1ed009f0b3d change_config '{
                        "new_config":{
                             "_bool":"false",
                             "_i256":"0x10",
                            "_u256":"0x20",
                            "_u8":"0x30",
                            "_i16":"0x40",
                            "_i7":"0x33",
                            "_u53":"0x60",
                            "dest":"0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
                            "cell":"",
                            "map":{}
                        }
                    }'
```

**Note**: One of the best ways to discover the right specification of arguments is to inspect return of the function
with the same return types:

```bash
$ tonos-cli -j run  --abi ../samples/25_Config.abi.json 0:d8782a0a8725f8015a09eaa850cdddf3e9c26e1f94e2ce73187534d01d348ee3 config {}
{
  "config": {
    "_bool": true,
    "_i256": "1",
    "_u256": "0x0000000000000000000000000000000000000000000000000000000000000002",
    "_u8": "3",
    "_i16": "4",
    "_i7": "5",
    "_u53": "6",
    "dest": "0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
    "cell": "te6ccgEBAQEAAgAAAA==",
    "map": {
      "0": "0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "1": "0:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdee"
    }
  }
}
```