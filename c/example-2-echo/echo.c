#include "echo.h"

// Variable x_persistent has _persistent suffix. This suffix instructs the
// compiler to keep the variable value in blockchain between contract
// methods invocations. Initialization takes place at deploy.
int x_persistent = 0;

// This method is declared in  the ABI as receiving and returning uint64 value.
// However,  all values are stored as 256-bit variables in TON VM.
// conversion from unit64 to 256-bit unsigned integer
// and back is carried out in wrapper by the compute() function.
unsigned compute_Impl (unsigned x) {
    ACCEPT();
    // The function argument is copied into persistent storage and
    // contents of x_persistent can be analyzed manually after the method
    // invocation.
    x_persistent = x;

    // Except for their save/restore semantics, persistent variables are not
    // different from other variables.
    return x_persistent;
}

// Implementation of the contract's constructor.
void constructor_Impl () {
    ACCEPT();
}
