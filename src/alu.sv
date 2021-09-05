typedef struct {
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
} regfile_pkt;


module ex(
    
);
endmodule


module alu(
    instr_field.ex instr_field,
    opcode_map.ex opcode_map,
    input regfile_pkt reg_pkt,
    output logic [31:0] result,
    input logic en
);

    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] imm_val;
    logic isSR;

    typedef enum {NOP, 
                  ADD, XOR, OR ,AND,
                  SLTU, SLT, SLL, SRL, SRA} funct3_t;
    funct3_t op;

    // sign extend
    assign imm_sext = {{20{instr_field.imm_i[11]}}, instr_field.imm_i};
    assign shamt_funct = instr_field.imm_i[11:5];
    assign shamt = instr_field.imm_i[4:0];

    assign a = reg_pkt.rs1_val;
    assign b = opcode_map.OP_IMM ? imm_sext : reg_pkt_rs2.val;
    
    assign isSR = !instr_field.imm_i[11] & instr_field.imm_i[9:5]; 

    always_comb begin : decode_op
        if (en) begin
            unique case (instr_field.funct3)
                3'b000 : // add/addi/sub 
                    op = ADD;
                3'b100 : // xor/xori
                    op = XOR;
                3'b110 : // or/ori
                    op = OR; 
                3'b111 : // and/andi
                    op = AND;
                3'b011 : // sltu/sltui
                    op = SLTU;
                3'b010 : // slt/slti
                    op = SLT;
                3'b001 : // sll/slli
                    op = (shamt_funct == 7'b0000000) ? SLL : NOP;
                3'b101 : // srl/srli/sra/srai
                    op = isSR ? (imm_i[10] ? SRA : SRL) : NOP;
            endcase
        end else begin
            op = NOP;
        end
    end

    always_comb begin : alu
        if (en) begin
            unique case (op)
                ADD : result = a + b;
                XOR : result = a ^ b;
                OR  : result = a | b;
                AND : result = a & b;
                SLTU : result = unsigned'(a) < unsigned'(b);
                SLT : result = signed'(a) < signed'(b); 
                SLL : result = a << b; 
                SRA : result = a >>> b;
                SRL : result = a >> b;
                default : result = 32'b0;
            endcase
        end else begin
            result = 32'b0;
        end
    end    
endmodule

