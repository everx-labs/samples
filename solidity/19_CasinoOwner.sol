pragma ton-solidity >= 0.35.0;

import "19_CasinoInterfaces.sol";

/// @title Casino owner smart contract.
/// @author TONLabs (https://github.com/tonlabs)


contract CasinoOwner is ICasinoOwner {

    // State variables:
    uint public m_casinoSeed; // modifier public creates a getter function with the same name as a state variable.
    address m_casino;

    constructor(address casino) public {
        require(tvm.pubkey() != 0, 103);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        m_casino = casino;
    }

    // Callback function to get seed value from the casino.
    function returnSeed(uint seed) public override {
        require(msg.sender == m_casino, 101);
        tvm.accept();
        m_casinoSeed = seed;
    }

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function updateSeed() public view onlyOwner {
        ICasino(m_casino).getSeed();
    }

    function withdrawBenefits() public view onlyOwner {
        ICasino(m_casino).withdrawBenefits();
    }

    function replenishCasino(uint128 value) public view onlyOwner {
        ICasino(m_casino).receiveFunds{value: value}();
    }

    receive() external pure {}
}



