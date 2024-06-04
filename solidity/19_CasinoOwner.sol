pragma tvm-solidity >= 0.72.0;

import "19_CasinoInterfaces.sol";

/// @title Casino owner smart contract.

contract CasinoOwner is ICasinoOwner {

    // State variables:
    uint public m_casinoSeed; // modifier public creates a getter function with the same name as a state variable.
    address m_casino;

    constructor(address casino) {
        require(tvm.pubkey() != 0, 103);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        m_casino = casino;
    }

    // Callback function to get seed value from the casino.
    function returnSeed(uint seed) external override {
        require(msg.sender == m_casino, 101);
        tvm.accept();
        m_casinoSeed = seed;
    }

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function updateSeed() external view onlyOwner {
        ICasino(m_casino).getSeed();
    }

    function withdrawBenefits() external view onlyOwner {
        ICasino(m_casino).withdrawBenefits();
    }

    function replenishCasino(coins value) external view onlyOwner {
        ICasino(m_casino).receiveFunds{value: value}();
    }

    receive() external pure {}
}
