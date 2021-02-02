pragma ton-solidity >= 0.35.0;

import "19_CasinoInterfaces.sol";

/// @title Casino owner smart contract.
/// @author TONLabs (https://github.com/tonlabs)


contract CasinoClient is ICasinoClient {

    // State variables:
    address m_casino;
    uint8 public m_lastCode;
    uint128 public m_lastComment;

    constructor(address casino) public {
        require(tvm.pubkey() != 0, 103);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        m_casino = casino;
    }

    // Callback function to get answer from the casino.
    function receiveAnswer(uint8 code, uint128 comment) public override {
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

    function setCasino(address casino) public onlyOwner {
        m_casino = casino;
    }

    function bet(uint128 value, uint8 number) public view onlyOwner {
        ICasino(m_casino).singleBet{value: value}(number);
    }

    function betDozen(uint128 value, uint8 number) public view onlyOwner {
        ICasino(m_casino).dozenBet{value: value}(number);
    }

    function betColumn(uint128 value, uint8 number) public view onlyOwner {
        ICasino(m_casino).columnBet{value: value}(number);
    }

    function betColor(uint128 value, bool isRed) public view onlyOwner {
        ICasino(m_casino).colorBet{value: value}(isRed);
    }

    function betGreatSmall(uint128 value, bool isGreat) public view onlyOwner {
        ICasino(m_casino).greatSmallBet{value: value}(isGreat);
    }

    function betParity(uint128 value, bool isEven) public view onlyOwner {
        ICasino(m_casino).parityBet{value: value}(isEven);
    }

    receive() external pure {}
}



