pragma tvm-solidity >= 0.72.0;
pragma AbiHeader expire;
import "24_IClient.sol";
import "24_ISquareProvider.sol";
import "24_LengthProvider.sol";
import "24_WidthProvider.sol";

struct Context {
    optional(uint32) width;
    optional(uint32) length;
    IClient client;
}

contract SquareProvider is ISquareProvider {
    WidthProvider m_widthProvider; // contract address that returns width of rectangle
    LengthProvider m_lengthProvider; // contract address that returns length of rectangle
    uint64 m_idRequest = 0; // sequence number for requests
    mapping(uint64 => Context) m_context; // for storing context of requests
    uint constant FEE = 2 ever; // some fee for storing context, calling another contracts, etc. Must be calculated more precisely
    uint constant MAX_TRANS_FEE = 0.5 ever; // max possible fee for `startGettingRectangleSquare` function. May be calculated more precisely

    constructor(address widthProvider, address lengthProvider) {
        require(tvm.pubkey() != 0, 100);
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_widthProvider = WidthProvider(widthProvider);
        m_lengthProvider = LengthProvider(lengthProvider);
    }

    function startGettingRectangleSquare() external override {
        // check if msg.value is enough for successful completion computing phase and reserving (on action phase)
        require(msg.value >= MAX_TRANS_FEE + FEE, 102);

        // these 2 lines have such effect: balance of the contract will be equal (original_balance + FEE)
        // and the sender will get the change from MAX_TRANS_FEE
        tvm.rawReserve(FEE, 4); // reserve original_balance + FEE.
        msg.sender.transfer({value: 0, flag: 128}); // return change

        // create and save context of call
        uint64 id = m_idRequest;
        ++m_idRequest;
        m_context[id] = Context(null, null, IClient(msg.sender));

        m_widthProvider.getWidth{value: 0.5 ever, callback: SquareProvider.onGetWidth}(id);
        m_lengthProvider.getLength{value: 0.5 ever, callback: SquareProvider.onGetLength}(id);
    }

    function onGetWidth(uint64 id, uint32 width) external {
        require(msg.sender == m_widthProvider);

        Context con = m_context.at(id);
        con.width = width;
        updateOrReturnValue(id, con);
    }

    function onGetLength(uint64 id, uint32 length) external {
        require(msg.sender == m_lengthProvider);

        Context con = m_context.at(id);
        con.length = length;
        updateOrReturnValue(id, con);
    }

    function updateOrReturnValue(uint64 id, Context con) private {
        if (!con.width.hasValue() || !con.length.hasValue()) {
            m_context[id] = con;
            return ;
        }

        // delete context and return value to client
        delete m_context[id];
        uint64 square = uint64(con.width.get()) * con.length.get();
        con.client.setRectangleSquare{value: 0.5 ever}(square);
    }
}

