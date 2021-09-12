// TEMP - Workaround for now since sv2v in place have some deficiencies
`define XLEN 32
`define ADDRWIDTH 32
`define BUSWIDTH 32

`include "registers.svh"
`include "typedef.svh"

module core
(
    input logic clk,
    input logic cpu_rstn,

    // master mem intf
    output logic [`ADDRWIDTH-1:0] rd_addr,
    output logic [`ADDRWIDTH-1:0] wr_addr,
    output logic [`BUSWIDTH-1:0] wr_data,
    output logic wren,

    input logic [`BUSWIDTH-1:0] rd_data
);

    logic [`XLEN-1:0] fetch_addr;
    logic fetch_addr_misaligned;
    
    logic next_pc_sel;

    logic [`XLEN-1:0] current_pc;
    logic [`XLEN-1:0] next_pc;
    logic [`XLEN-1:0] pc_plus_4;
    logic [`XLEN-1:0] instruction;

    logic [`XLEN-1:0] target_address;

    instr_field i_field_pkt;
    opcode_map op_decode_pkt;
    
    assign target_address = 32'b0;

    assign pc_plus_4 = current_pc + 4; 
    assign fetch_addr = current_pc;
    assign next_pc = next_pc_sel ? target_address : pc_plus_4;
    
    // instruction address should be located at 32 bit boundary, 
    // ie divisible by 4 byte
    // alignment implies => fetch_addr & 2^2-1 == 0 
    assign fetch_addr_misaligned = fetch_addr[0] | fetch_addr[1] | fetch_addr[2];
    assign next_pc_sel = 1'b0; // temp for now

    // Start behavioral ram assignments
    // TODO use actual bus interface or NoC architecture
    assign rd_addr = current_pc;
    // Don't care about writes to imem for now just initialize to 0 
    assign wr_addr = 0;
    assign wr_data = 0; 
    assign wren = 0; 
    assign instruction = rd_data;
    // End behavioral ram assignments

    `FF(current_pc, next_pc, 0, clk, cpu_rstn);

    decoder decode(
        .i(instruction),
        .i_field_pkt(i_field_pkt),
        .op_decode_pkt(op_decode_pkt)
    );

    `ifdef FORMAL
    `ifdef YOSYS
        `include "formal_tb_frag.svh"
    `endif
    `endif

endmodule
