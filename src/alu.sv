`include "defines.svh"
`include "typedef.svh"

module alu (
    input logic [`XLEN-1:0] a,
    input logic [`XLEN-1:0] b,
    input alu_op_t op,
    output logic [`XLEN-1:0] result,
    output logic EQ,
    output logic NE,
    output logic LT,
    output logic LTU,
    output logic GE,
    output logic GEU
);

    logic [`XLEN-2:0] zeros;
    logic cmp_EQ, cmp_NE, cmp_LT, cmp_LTU, cmp_GE, cmp_GEU;  
    
    assign zeros = 0;

    always_comb begin : result_mux
        unique case (op)
            AND : result = a & b;
            OR  : result = a | b;
            XOR : result = a ^ b;
            SLT : result = {zeros, cmp_LT};
            SLTU : result = {zeros, cmp_LTU};
            SLL : result = a << b[4:0]; 
            SRA : result = a >>> b[4:0];
            SRL : result = a >> b[4:0];
            ADD : result = a + b;
            NOP: result = 0; 
            default : result = 'x;
        endcase
    end

    always_comb begin : compare
        cmp_EQ = a == b;
        cmp_NE = ~cmp_EQ;
        cmp_LT = signed'(a) < signed'(b);
        cmp_LTU = unsigned'(a) < unsigned'(b);
        cmp_GE = ~cmp_LT;
        cmp_GEU = ~cmp_LTU;
    end

    assign EQ = cmp_EQ;
    assign NE = cmp_NE;
    assign LT = cmp_LT;
    assign LTU = cmp_LTU;
    assign GE = cmp_GE;
    assign GEU = cmp_GEU;

endmodule