pragma ton-solidity >= 0.44.0;
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
    uint constant FEE = 2 ton; // some fee for storing context, calling another contracts, etc. Must be calculate more precisely

    constructor(address widthProvider, address lengthProvider) public {
        require(tvm.pubkey() != 0, 100);
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_widthProvider = WidthProvider(widthProvider);
        m_lengthProvider = LengthProvider(lengthProvider);
    }

    function startGettingRectangleSquare() external override {
        tvm.rawReserve(FEE, 4); // reserve original_balance + FEE
        msg.sender.transfer({value: 0, flag: 128}); // return charge

        // create and save context of call
        uint64 id = m_idRequest;
        ++m_idRequest;
        m_context[id] = Context(null, null, IClient(msg.sender));

        m_widthProvider.getWidth{value: 0.5 ton, callback: SquareProvider.onGetWidth}(id);
        m_lengthProvider.getLength{value: 0.5 ton, callback: SquareProvider.onGetLength}(id);
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
        con.client.setRectangleSquare{value: 0.5 ton}(square);
    }
}

