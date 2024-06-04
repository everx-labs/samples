pragma tvm-solidity >= 0.72.0;

import "19_CasinoInterfaces.sol";

/// @title Casino owner smart contract.

contract CasinoClient is ICasinoClient {

    // State variables:
    address m_casino;
    uint8 public m_lastCode;
    uint128 public m_lastComment;

    constructor(address casino) {
        require(tvm.pubkey() != 0, 103);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        m_casino = casino;
    }

    // Callback function to get answer from the casino.
    function receiveAnswer(uint8 code, uint128 comment) external override {
        require(msg.sender == m_casino, 101);
        tvm.accept();
        m_lastCode = code;
        m_lastComment = comment;
    }

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function setCasino(address casino) external onlyOwner {
        m_casino = casino;
    }

    function bet(coins value, uint8 number) external view onlyOwner {
        ICasino(m_casino).singleBet{value: value}(number);
    }

    function betDozen(coins value, uint8 number) external view onlyOwner {
        ICasino(m_casino).dozenBet{value: value}(number);
    }

    function betColumn(coins value, uint8 number) external view onlyOwner {
        ICasino(m_casino).columnBet{value: value}(number);
    }

    function betColor(coins value, bool isRed) external view onlyOwner {
        ICasino(m_casino).colorBet{value: value}(isRed);
    }

    function betGreatSmall(coins value, bool isGreat) external view onlyOwner {
        ICasino(m_casino).greatSmallBet{value: value}(isGreat);
    }

    function betParity(coins value, bool isEven) external view onlyOwner {
        ICasino(m_casino).parityBet{value: value}(isEven);
    }

    receive() external pure {}
}


