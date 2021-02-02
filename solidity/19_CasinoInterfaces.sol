pragma ton-solidity >= 0.35.0;

// Interface of the Casino contract.
interface ICasino {
    function singleBet(uint8 number) external view;
    function dozenBet(uint8 number) external view;
    function columnBet(uint8 number) external view;
    function greatSmallBet(bool isGreat) external view;
    function parityBet(bool isEven) external view;
    function colorBet(bool isRed) external view;
    function getSeed() external view;
    function withdrawBenefits() external view;
    function receiveFunds() external pure;
}

interface ICasinoClient {
    function receiveAnswer(uint8 code, uint128 comment) external;
}

interface ICasinoOwner {
    function returnSeed(uint seed) external;
}
