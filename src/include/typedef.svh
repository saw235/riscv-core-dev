`ifndef _TYPEDEF_
`define _TYPEDEF_

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
} regval;

`endif