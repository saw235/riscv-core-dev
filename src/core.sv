`define XLEN 32

`include "registers.svh"
`include "prim_assert.sv"

// A macro to emulate |-> (a syntax that Yosys doesn't currently support).
`define IMPLIES(a, b) ((b) || (!(a))) 

module core(
    input logic clk,
    input logic cpu_rstn
);

    logic [`XLEN-1:0] fetch_addr;
    logic fetch_addr_misaligned;
    
    logic next_pc_sel;

    logic [`XLEN-1:0] current_pc;
    logic [`XLEN-1:0] next_pc;
    logic [`XLEN-1:0] pc_plus_4;
    logic [`XLEN-1:0] instruction;

    logic [`XLEN-1:0] target_address;

    mem_intf imem_if (.clk(clk));

    
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
    assign imem_if.rd_addr = current_pc;
    // Don't care about writes to imem for now just initialize to 0 
    assign imem_if.wr_addr = 0;
    assign imem_if.wr_data = 0; 
    assign imem_if.wren = 0; 
    assign instruction = imem_if.rd_data;
    // End behavioral ram assignments

    `FF(current_pc, next_pc, 0, clk, cpu_rstn);

    mem instr_mem (
        .intf(imem_if)
    );


//     property raise_misalign;
//         !(current_pc % 4 == 0) |-> fetch_addr_misaligned;
//     endproperty
//     assert property raise_misalign (@ (posedge clk)) else display "Fetch address misaligned but error is not raised.";

`ifdef FORMAL
    `ASSERT(raise_misalign, `IMPLIES(!(current_pc % 4 == 0), !fetch_addr_misaligned), clk, cpu_rstn)
`endif

endmodule


interface mem_intf #(
    parameter integer BUSWIDTH = 32,
    parameter integer ADDRWIDTH = 32 
)(
    input logic clk
);
    logic [ADDRWIDTH-1:0] rd_addr;
    logic [ADDRWIDTH-1:0] wr_addr;
    logic [BUSWIDTH-1:0] wr_data;
    logic wren;

    logic [BUSWIDTH-1:0] rd_data;

    modport mem(
        input rd_addr, wr_addr, wr_data, wren, clk,
        output rd_data
    );

endinterface

// simple behavioral ram model
// not meant for synthesis
module mem #(
    parameter integer RAMDEPTH = 2 ** 10,  
    parameter integer BUSWIDTH = 32,
    parameter integer ADDRWIDTH = 32
)(
    mem_intf.mem intf
);

    logic [BUSWIDTH-1:0] local_mem [0:RAMDEPTH-1];
    
    always_ff @(posedge intf.clk) begin
        intf.rd_data <= local_mem[intf.rd_addr];

        if (intf.wren) begin
            local_mem[intf.wr_addr] <= intf.wr_data;
        end
    end

endmodule