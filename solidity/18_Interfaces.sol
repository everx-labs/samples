pragma ton-solidity >= 0.35.0;

// Interface of the database contract.
interface IOrderDatabase {
    function createAnOrder(uint amount, uint32 duration) external;
}

// Interface of the client contract.
interface IClient {
    function setOrderKey(uint40 key) external;
}