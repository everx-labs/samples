pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;
import "24_IClient.sol";
import "24_ISquareProvider.sol";

contract Client is IClient {
    ISquareProvider m_provider;
    uint64 public m_square;

    constructor(ISquareProvider provider) {
        require(tvm.pubkey() != 0, 100);
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_provider = provider;
    }

    function getRectangleSquare() external view {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_provider.startGettingRectangleSquare{value: 5 ever}();
    }

    function setRectangleSquare(uint64 square) external override {
        require(msg.sender == m_provider, 101);
        m_square = square;
    }
}
