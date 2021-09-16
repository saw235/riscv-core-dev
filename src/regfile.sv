`include "defines.svh"
`ifdef FORMAL
    `include "prim_assert.sv"
`endif

// dual port 32 registers regfile
module regfile_32b(
    input logic [4:0] r0addr,
    input logic [4:0] r1addr,
    output logic [31:0] r0data,
    output logic [31:0] r1data,
    input logic [4:0] waddr,
    input logic [31:0] wdata,
    input logic wren,
    input logic clk
);
    
    logic [31:0]regs[1:31];
    integer i;

    always_ff @(posedge clk) begin
            r0data <= (r0addr == 0) ? 0 : regs[r0addr];
            r1data <= (r1addr == 0) ? 0 : regs[r1addr];

            if (wren) begin
                regs[waddr] <= wdata;
            end
        
    end

    `ifdef FORMAL
        `ASSUME_I(read_exclusive, r0addr !== r1addr)
        `ASSERT(r0_x0, `IMPLIES($past(r0addr == 0), r0data == 0), clk, 1'b1)
        `ASSERT(r1_x0, `IMPLIES($past(r1addr == 0), r1data == 0), clk, 1'b1)
    `endif

endmodule