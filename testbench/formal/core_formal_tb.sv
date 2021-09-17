`include "prim_assert.sv"
`include "defines.svh"

module formal_tb(
    input logic fetch_addr_misaligned,
    input logic [`XLEN-1:0] current_pc,
    input logic clk,
    input logic cpu_rstn    
);

//     property raise_misalign;
//         !(current_pc % 4 == 0) |-> fetch_addr_misaligned;
//     endproperty
//     assert property raise_misalign (@ (posedge clk)) else display "Fetch address misaligned but error is not raised.";

    `ASSERT(raise_misalign, `IMPLIES((current_pc % 4 !== 0), fetch_addr_misaligned), clk, cpu_rstn)

endmodule