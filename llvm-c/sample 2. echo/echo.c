#include "echo.h"

// Variable x_persistent has _persistent suffix. This suffix instructs the 
// compiler to keep the variable value in blockchain between contract
// methods invocations. Initialization happens at the moment of contract 
// deploy.
int x_persistent = 0;

// This method is declared in ABI as receiving and returning uint64 value. 
// However, inside TVM virtual machine all integer values are kept as
// 256-bit values. The conversion from unit64 to 256-bit unsigned integer
// and back is carried out in wrapper - in function compute().
unsigned compute_Impl (unsigned x) {

    // The argument of the function is copied into persistent storage and
    // contents of x_persistent may be manually analyzed after the method 
    // invocation.
    x_persistent = x;

    // Except for their save/restore semantics, persistent variables are in no 
    // other way different from other variables.
    return x_persistent;
}
