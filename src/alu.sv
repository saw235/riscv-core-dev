`include "defines.svh"
`include "typedef.svh"

module alu (
    input logic [`XLEN-1:0] a,
    input logic [`XLEN-1:0] b,
    output logic [`XLEN-1:0] result,
    input alu_op_t op
);

    logic [`XLEN-2:0] zeros;
    
    assign zeros = 0;

    always_comb begin
        unique case (op)
            AND : result = a & b;
            OR  : result = a | b;
            XOR : result = a ^ b;
            SLT : result = {zeros, signed'(a) < signed'(b)};
            SLTU : result = {zeros, unsigned'(a) < unsigned'(b)};
            SLL : result = a << b; 
            SRA : result = a >>> b;
            SRL : result = a >> b;
            ADD : result = a + b;
            NOP: result = 0; 
            default : result = `XLEN'bx;
        endcase
    end

endmodule