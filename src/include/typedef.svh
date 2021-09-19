`ifndef _TYPEDEF_
`define _TYPEDEF_

typedef enum logic[3:0] {
    ADD     = 4'b0000,
    SLL     = 4'b0001, 
    SLT     = 4'b0010, 
    SLTU    = 4'b0011, 
    XOR     = 4'b0100, 
    SRL     = 4'b0101,
    OR      = 4'b0110, 
    AND     = 4'b0111, 
    SRA     = 4'b1101,
    NOP     = 4'b1000 
} alu_op_t;

typedef struct packed {
    logic LOAD;
    logic LOAD_FP;
    logic MISC_MEM;
    logic OP_IMM;
    logic AUIPC;
    logic OP_IMM_32;
    logic STORE;
    logic STORE_FP;
    logic AMO;
    logic OP;
    logic LUI;
    logic OP_32;
    logic MADD;
    logic MSUB;
    logic NMSUB;
    logic NMADD;
    logic OP_FP;
    logic BRANCH;
    logic JALR;
    logic JAL;
    logic SYSTEM;
} opcode_map;

typedef struct packed {
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [4:0] rd;
    logic [6:0] opcode;
    logic [11:0] imm_i;
    logic [11:0] imm_s;
    logic [11:0] imm_b;
    logic [19:0] imm_u;
    logic [19:0] imm_j;
} instr_field;

typedef struct packed {
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
} regval_t;

typedef struct packed {  
    logic ADDI;
    logic SLTI;
    logic SLTIU;
    logic XORI;
    logic ORI;
    logic ANDI;
    logic SLLI;
    logic SRLI;
    logic SRAI;

    logic LUI;
    logic AUIPC;
    logic JAL;
    logic JALR;

    logic ADD;
    logic SUB;
    logic SLL;
    logic SLT;
    logic SLTU;
    logic XOR;
    logic SRL;
    logic SRA;
    logic OR;
    logic AND;

    logic BEQ;
    logic BNE;
    logic BLT;
    logic BGE;
    logic BLTU;
    logic BGEU;

    logic LB;
    logic LH;
    logic LW;
    logic LBU;
    logic LHU;

    logic SB;
    logic SH;
    logic SW;
} instruction_decode_t;

`endif