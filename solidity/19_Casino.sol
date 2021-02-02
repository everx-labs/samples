pragma ton-solidity >= 0.35.0;

import "19_CasinoInterfaces.sol";

/// @title Casino roulette smart contract.
/// @author TONLabs (https://github.com/tonlabs)

// Possible bets:                                                                     | Payout (number of bets in addition to the original bet)
// 1) Single - bet on the single number from 0 to 36;                                 | 35
// 2) Dozen - bet on the dozen of numbers: from 1 to 12, 13-...-24, 25-...-36;        | 2
// 3) Column - bet on the column of numbers: 1-4-...-34, 2-5-...-35, 3-6-...-36;      | 2
// 4) Great/Small - bet on righteen numbers: from 1 to 18 or from 19 to 36;           | 1
// 5) Even/Odd - bet on all even or odd numbers;                                      | 1
// 6) Red/Black - bet on all red or black numbers.                                    | 1


contract Casino is ICasino {

    /// @dev Event emitted when Casino balance becomes too low.
    /// @param replenishment Minimal value that must be sent to Casino (via 'receiveFunds' function) to reach minimal balance.
    event TooLowBalance(uint replenishment);

    // Error codes: 
    uint constant ERROR_NO_PUBKEY = 101;
    uint constant ERROR_SENDER_IS_NOT_OWNER = 102;
    uint constant ERROR_BAD_ASSURANCE = 103;

    // Status codes that returned to the client:
    uint8 constant STATUS_WIN = 0;
    uint8 constant STATUS_CASINO_HAS_LOW_BALANCE = 1;
    uint8 constant STATUS_BET_IS_TOO_LOW = 2;
    uint8 constant STATUS_BET_IS_TOO_HIGH = 3;
    uint8 constant STATUS_LOSS = 4;
    uint8 constant STATUS_WRONG_NUMBER = 5;

    // State variables:
    uint128 public m_minimalBalance;
    uint128 public m_minimalBet;
    address public m_ownerWallet;

    /// @dev Casino's constructor.
    /// @param casinoAssurance Minimal balance of the Casino that should be able to cover every possible winning.
    /// @param minimalBet Minimal bet, that user can be places.
    /// @param ownerWallet Address of the owner's wallet to send benefits.
    constructor (
        uint128 casinoAssurance,
        uint128 minimalBet,
        address ownerWallet
    ) 
    public {
        // Check that contract's public key is set.
        require(tvm.pubkey() != 0, ERROR_NO_PUBKEY);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key.
        require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
        // Check that minimal balance exceeds the maximal payout with specified minimal bet.
        require(casinoAssurance >= 35 * minimalBet, ERROR_BAD_ASSURANCE);
        // Accept the message.
        tvm.accept();
        // Initialize the state variables.
        m_minimalBalance = casinoAssurance;
        m_minimalBet = minimalBet;
        m_ownerWallet = ownerWallet;
    }

    /// @dev Modifier that accepts only messages that were signed by the owners key or sent from the owner's wallet.
    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey() ||
            msg.sender == m_ownerWallet,
            ERROR_SENDER_IS_NOT_OWNER);
        tvm.accept();
        _;
    }

    /// @dev Function for the owner to withdraw all contract's balance that exceeds minimal balance.
    function withdrawBenefits() public view onlyOwner override {
        uint128 minBalance = m_minimalBalance;
        // Check whether balance of the contract exceeds the minimal balance.
        if (address(this).balance < minBalance) {
            // If balance is too low, contract emits an event that can be caught by the owner,
            // who should replenish the contract's balance.
            emit TooLowBalance(minBalance - address(this).balance);
            // Function tvm.exit() can be used to quickly terminate execution of the smart contract
            // with exit code equal to zero.
            tvm.exit();
        }
        // Function tvm.rawReserve() allows to reserve some value on the balance of the contract.
        // Here we reserve value exactly equal to minimal balance.
        tvm.rawReserve(m_minimalBalance, 0);
        // Transfer all contract funds (except reserved minimal balance) to the owner's wallet.
        m_ownerWallet.transfer({value:0, bounce: false, flag: 128});
    }

    /// @dev Function for the owner to get the Casino's random seed.
    function getSeed() public view onlyOwner override {
        // Function rnd.getSeed() returns the current random seed.
        uint seed = rnd.getSeed();
        ICasinoOwner(m_ownerWallet).returnSeed(seed);
    }

    /// @dev Internal function to get a random number from 0 to 36.
    function getNumber() private pure inline returns(uint8) {
        reshuffleCasino();
        // Function rnd.next() generates a pseudo-random number, the
        // result of the function is taken modulo the argument number.
        uint8 number = rnd.next(uint8(37));
        return number;
    }

    /// @dev Internal function that returns an answer to the client.
    function sendAnswer(uint8 code, uint128 comment, bool returnChange) private pure {
        if (returnChange)
            // Call clients function and attach all the remaining value of the inbound message.
            ICasinoClient(msg.sender).receiveAnswer{value: 0, bounce: false, flag: 64}(code, comment);
        else
            // Call client with fixed value.
            ICasinoClient(msg.sender).receiveAnswer{value: 10 milliton, bounce: false, flag: 1}(code, comment);
    }

    /// @dev Internal function that performs common checks.
    function checkBet(uint128 bet, uint8 payoutMultiplier, uint128 minBalance) private view returns (bool) {
        uint128 balance = address(this).balance;
        // Check that Casino's balance is greater or equal than minimal.
        if (balance < minBalance) {
            // In case of low balance send an error to the client.
            sendAnswer(STATUS_CASINO_HAS_LOW_BALANCE, 0, true);
            // And emit an event for the owner.
            emit TooLowBalance(minBalance - balance);
            return false;
        }
        uint128 minBet = m_minimalBet;
        // Check that client's bet is greater or equal than minimal.
        if (bet < minBet) {
            // In case of low bet send an error to the client.
            sendAnswer(STATUS_BET_IS_TOO_LOW, minBet, true);
            return false;
        }
        uint128 maxBet = minBalance / payoutMultiplier;
        // Check that client's bet is less or equal than maximal.
        if (bet > maxBet) {
            // In case of high bet send an error to the client.
            sendAnswer(STATUS_BET_IS_TOO_HIGH, maxBet, true);
            return false;
        }
        return true;
    }

    /// @dev Internal function that performs after roll actions.
    function finishBet(bool hasWon, uint128 payout, uint8 rouletteNumber, uint128 minBalance) private pure {
        if (hasWon) {
            if (address(this).balance - payout < minBalance) {
                emit TooLowBalance(minBalance - address(this).balance + payout);
            }
            msg.sender.transfer({value: payout, bounce: false});
            sendAnswer(STATUS_WIN, 0, false);
        } else {
            sendAnswer(STATUS_LOSS, rouletteNumber, false);
        }
    }

    /// @notice Start a roulette with bet on a single number.
    /// @param number Number that bet placed on. Should be from 0 to 36.
    function singleBet(uint8 number) public view override {
        uint128 bet = msg.value;
        uint8 payoutMultiplier = 36;
        uint128 minBalance = m_minimalBalance;
        // Perform preliminary checks.
        if (!checkBet(bet, payoutMultiplier, minBalance)) {
            // Exit if check has failed.
            return;
        }
        // Check that bet number is valid.
        if (number > 36) {
            // In case of bad number send an error to the client.
            sendAnswer(STATUS_WRONG_NUMBER, 0, true);
            return;
        }
        uint8 rouletteNumber = getNumber();
        finishBet(rouletteNumber == number,
            bet * payoutMultiplier,
            rouletteNumber,
            minBalance);
    }

    /// @notice Start a roulette with bet on a dozen.
    /// @param number Number of dozen bet placed on. Should be from 1 to 3.
    /// 1 = 1 - 12
    /// 2 = 13 - 24
    /// 3 = 25 - 36
    function dozenBet(uint8 number) public view override {
        uint128 bet = msg.value;
        uint8 payoutMultiplier = 3;
        uint128 minBalance = m_minimalBalance;
        // Perform preliminary checks.
        if (!checkBet(bet, payoutMultiplier, minBalance)) {
            // Exit if check has failed.
            return;
        }
        // Check that bet number is valid.
        if (number > 3 || number == 0) {
            // In case of bad number send an error to the client.
            sendAnswer(STATUS_WRONG_NUMBER, 0, true);
            return;
        }
        uint8 rouletteNumber = getNumber();
        // Function math.divc() returns result of the division of two numbers with ceiling
        // rounding mode.
        bool hasWon = math.divc(rouletteNumber, 12) == number;
        finishBet(hasWon,
            bet * payoutMultiplier,
            rouletteNumber,
            minBalance);
    }

    /// @notice Start a roulette with bet on a column.
    /// @param number Number of column bet placed on. Should be from 1 to 3.
    /// 1 = 1-4-7-...-34
    /// 2 = 2-5-8-...-35
    /// 3 = 3-6-9-...-36
    function columnBet(uint8 number) public view override {
        uint128 bet = msg.value;
        uint8 payoutMultiplier = 3;
        uint128 minBalance = m_minimalBalance;
        // Perform preliminary checks.
        if (!checkBet(bet, payoutMultiplier, minBalance)) {
            // Exit if check has failed.
            return;
        }
        // Check that bet number is valid.
        if (number > 3 || number == 0) {
            // In case of bad number send an error to the client.
            sendAnswer(STATUS_WRONG_NUMBER, 0, true);
            return;
        }
        uint8 rouletteNumber = getNumber();
        uint8 column = (rouletteNumber % 3);
        if (column == 0 && rouletteNumber != 0)
            column += 3;
        finishBet(column == number,
            bet * payoutMultiplier,
            rouletteNumber,
            minBalance);
    }

    /// @notice Start a roulette with bet on great or small.
    /// @param isGreat Indicates whether bet is placed on the great half of numbers.
    /// true = 19 - 36
    /// false = 1 - 18
    function greatSmallBet(bool isGreat) public view override {
        uint128 bet = msg.value;
        uint8 payoutMultiplier = 2;
        uint128 minBalance = m_minimalBalance;
        // Perform preliminary checks.
        if (!checkBet(bet, payoutMultiplier, minBalance)) {
            // Exit if check has failed.
            return;
        }
        
        uint8 rouletteNumber = getNumber();
        bool hasWon = false;
        if (rouletteNumber != 0)
            hasWon = ((rouletteNumber >= 19) == isGreat);
        finishBet(hasWon,
            bet * payoutMultiplier,
            rouletteNumber,
            minBalance);
    }

    /// @notice Start a roulette with bet on even or odd.
    /// @param isEven Indicates whether bet is placed on the even numbers.
    /// true = even numbers
    /// false = odd numbers
    function parityBet(bool isEven) public view override {
        uint128 bet = msg.value;
        uint8 payoutMultiplier = 2;
        uint128 minBalance = m_minimalBalance;
        // Perform preliminary checks.
        if (!checkBet(bet, payoutMultiplier, minBalance)) {
            // Exit if check has failed.
            return;
        }
        
        uint8 rouletteNumber = getNumber();
        bool hasWon = false;
        if (rouletteNumber != 0)
            hasWon = (((rouletteNumber % 2) == 1) == !isEven);
        finishBet(hasWon,
            bet * payoutMultiplier,
            rouletteNumber,
            minBalance);
    }

    /// @notice Start a roulette with bet on red or black.
    /// @param isRed Indicates whether bet is placed on the red numbers.
    /// true = red numbers
    /// false = black numbers
    function colorBet(bool isRed) public view override {
        uint128 bet = msg.value;
        uint8 payoutMultiplier = 2;
        uint128 minBalance = m_minimalBalance;
        // Perform preliminary checks.
        if (!checkBet(bet, payoutMultiplier, minBalance)) {
            // Exit if check has failed.
            return;
        }
        
        uint8 rouletteNumber = getNumber();
        bool hasWon = false;
        if (rouletteNumber != 0) {
            if (rouletteNumber <= 10 || 
            (rouletteNumber >= 19 && rouletteNumber <= 28)) {
                hasWon = ((rouletteNumber % 2) == 1) == isRed;
            } else {
                hasWon = ((rouletteNumber % 2) == 1) != isRed;
            }
        }
        finishBet(hasWon,
            bet * payoutMultiplier,
            rouletteNumber,
            minBalance);
    }

    /// @dev Internal funciton to reshuffle Casino's random to be sure in it's honour.
    function reshuffleCasino() private pure {
        uint repeatCnt = 10;
        // `repeat()` construction allows to repeat block of code a given number of times.
        // It works more economical than `while` or `for`, but allows to repeat construction
        // only definite number of times, because it reads the value of the argument at the
        // beginning and repeats code this number of times despite the possible changes of
        // the argument variable.
        repeat(repeatCnt) {
            // Function rnd.shuffle() randomizes the random seed based on the logical time
            // of the current transaction.
            rnd.shuffle();
        }
    }

    /// @dev Function to replenish Casino's balance.
    function receiveFunds() public pure override {
    }

    /// @notice receive function just returns funds for not to be mixed up with bet.
    receive() external pure {
        msg.sender.transfer(0, false, 64);
    }

    /// @notice fallback function just returns funds for not to be mixed up with bet.
    fallback() external pure {
        msg.sender.transfer(0, false, 64);
    }
}
