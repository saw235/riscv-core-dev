// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vtb_top.h"

int main(int argc, char** argv, char** env) {
    // See a similar example walkthrough in the verilator manpage.

    // This is intended to be a minimal example.  Before copying this to start a
    // real project, it is better to start with a more complete example,
    // e.g. examples/c_tracing.

    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v"
    Vtb_top* tb_top = new Vtb_top;

    int cycles = 0;
    int testdone = 0;

        // Simulate until $finish
    while (!Verilated::gotFinish()) {
        tb_top->clk = ~tb_top->clk;
    
        // Evaluate model
        tb_top->eval();
    }

    // Final model cleanup
    tb_top->final();

    // Destroy model
    delete tb_top;

    // Return good completion status
    return 0;
}
