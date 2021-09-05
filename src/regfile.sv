// dual port 32 registers regfile
module regfile(
    input logic [4:0] r0addr,
    input logic [4:0] r1addr,
    output logic [31:0] r0data,
    output logic [31:0] r1data,
    input logic [4:0] waddr,
    input logic [31:0] wdata,
    input logic wren,
    input logic clk,
    input logic nrst
);
    
    logic [31:0]regs[1:31];
    integer i;

    always_ff @(posedge clk & negedge nrst) begin
        if (!nrst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 0;
            end
        end else begin
            r0data <= regs[r0addr];
            r1data <= regs[r1addr];

            if (wren) begin
                regs[waddr] <= wdata;
            end
        end
    end
endmodule