pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;

// Example of a structure with different fields
struct Config {
    // boolean field
    bool _bool;
    // integer fields
    int _i256;
    uint _u256;
    uint8 _u8;
    int16 _i16;
    int7 _i7;
    uint53 _u53;
    // address type
    address dest;
    // cell type
    TvmCell cell;
    // mapping type
    mapping(uint128 => address) map;
}

contract ConfigContract {
    
    // State variable that stores current config
    Config public config;
    
    // Constructor function that initializes config
    constructor(Config initial_config) {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        // store the initial config
        config = initial_config;
    }

    function change_config(Config new_config) external {
        // Check that message was signed with contracts key.
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        config = new_config;
    }

}
