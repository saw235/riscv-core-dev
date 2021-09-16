`ifndef __GLOBAL_DEFINES__
`define __GLOBAL_DEFINES__

`define XLEN 32
`define ADDRWIDTH 32
`define BUSWIDTH 32

// A macro to emulate |-> (a syntax that Yosys doesn't currently support).
`define IMPLIES(a, b) ((b) || (!(a))) 

`endif