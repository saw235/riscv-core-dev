// Alu supports the follow operation
//
// - AND/OR/XOR
// - SLT/SLTU (Set less than)
// - SLL/SRL/SRA
// - ADD

typedef enum logic[3:0] {NOP, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA, ADD} alu_op_t;

module alu #(parameter integer NBIT = 32)(
    input logic [NBIT-1:0] a,
    input logic [NBIT-1:0] b,
    input alu_op_t op,
    output logic [NBIT-1:0] result

);

    always_comb begin
        unique case (op)
            AND : result = a & b;
            OR  : result = a | b;
            XOR : result = a ^ b;
            SLT : result = signed'(a) < signed'(b);
            SLTU : result = unsigned'(a) < unsigned'(b);
            SLL : result = a << b; 
            SRA : result = a >>> b;
            SRL : result = a >> b;
            ADD : result = a + b;
            NOP: result = 0; 
            default : result = 0;
        endcase
    end

endmodule : alu