package pkg;

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

typedef struct {
    logic funct7[6:0];
    logic funct3[2:0];
    logic rs2[4:0];
    logic rs1[4:0];
    logic rd[4:0];
    logic opcode[6:0];
    logic imm_i[11:0];
    logic imm_s[11:0];
    logic imm_b[11:0];
    logic imm_u[19:0];
    logic imm_j[19:0];
} instr_field;

typedef struct {
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
} regval;

endpackage