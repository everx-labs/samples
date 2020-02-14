#include "ton-sdk/tvm.h"
#include "ton-sdk/messages.h"
#include "ton-sdk/smart-contract-info.h"

// Custom exception declaration

// This exception is thrown when the account is required to
// transfer money before the target amount is accumulated.
TVM_CUSTOM_EXCEPTION (NOT_ENOUGH_MONEY, 61);

// Target amount initialization may be performed only once:
// otherwise one could easily evade "target" amount limitation.
TVM_CUSTOM_EXCEPTION (ALREADY_INITIALIZED, 62);

enum { MESSAGE_COST = 10000000 };

// Target amount of money: piggybank ensures that the contract
// owner accumulates this amount before they can spend the
// money.
int target_persistent = MESSAGE_COST;

void constructor_Impl () {
    tvm_accept();
}

// Used to specify the target amount of money in nanograms.
// The money cannot be decreased: if method initialize_limit
// was invoked with a larger value, its re-initialization with
// smaller value results in error.
void initialize_target_Impl (unsigned target) {
    tvm_assert (target_persistent > target, ALREADY_INITIALIZED);
    tvm_accept();
    target_persistent = target;
}

// Main piggybank method: withdraw all money from the piggybank
// account. Can be activated if the account accumulated the
// "target" amount of money. If not, the method throws
// NOT_ENOUGH_MONEY exception.
void transfer_Impl (unsigned destination_account) {
    tvm_accept();
    // Check that we have collected enough money to transfer it.
    // Info about the current account state (including current contract
    // gram balance) is stored in SmartContractInfo structure -
    // see TON blockchain docs for more info.
    SmartContractInfo sc_info = get_SmartContractInfo();
    int balance = sc_info.balance_remaining.grams.amount.value;
    tvm_assert (balance >= target_persistent, NOT_ENOUGH_MONEY);

    //Once we collected enough money and can retrieve
    // it! In this case, send the message to the contract to
    // transfer the money to the destination address.
    MsgAddressInt destination =
        build_msg_address_int (0, destination_account);
    build_internal_message (&destination, balance - MESSAGE_COST);
    send_raw_message (MSG_PAY_FEES_SEPARATELY);
}
