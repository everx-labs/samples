pragma ton-solidity >=0.32.0;
pragma AbiHeader expire;

interface ISink {
    function receive0(uint _a, uint _b) external;
}

interface IBomber {
    function testValue0Flag64() external;
    function testValue1Flag64() external;
    function testValue1Flag65() external;
}