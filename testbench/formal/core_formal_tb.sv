`include "prim_assert.sv"
`include "defines.svh"
`include "typedef.svh"

module formal_tb(
    input logic fetch_addr_misaligned,
    input logic [`XLEN-1:0] current_pc,
    input logic clk,

    input logic [`XLEN-1:0] alu_result,

    input logic alu_eq,
    input logic alu_ne,
    input logic alu_lt,
    input logic alu_ltu,
    input logic alu_ge,
    input logic alu_geu,

    input instruction_decode_t instruction_decode_pkt,
    input opcode_map op_decode_pkt,
    input logic is_illegal_instruction,

    input logic cpu_rstn    
);

//     property raise_misalign;
//         !(current_pc % 4 == 0) |-> fetch_addr_misaligned;
//     endproperty
//     assert property raise_misalign (@ (posedge clk)) else display "Fetch address misaligned but error is not raised.";

    `ASSERT(raise_misalign, `IMPLIES((current_pc % 4 !== 0), fetch_addr_misaligned), clk, ~cpu_rstn)
    
    // instructions are mutually exclusive
    `ASSERT_I(exclusive_instruction, is_illegal_instruction | $onehot(instruction_decode_pkt))

    

endmodule