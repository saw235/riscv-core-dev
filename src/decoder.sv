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

typedef struct;
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

module decoder(
    input logic [31:0] i, // instruction
    output instr_field i_field_pkt,
    output opcode_map op_decode_pkt
);

// .extract
// funct7 = 31..25
// funct3 = 14..12
// rs2 = 24..20
// rs1 = 19..15
// rd = 11..7
// opcode = 6..0
// imm_i = 31..20
// imm_s = 31..25 11..7
// imm_b = 31 7..6 30..25 11..8   = 1 + 2 + 6 + 4
// imm_u = 31..12
// imm_j = 31 19..12 20 30..21   = 1 + 8 + 1 + 10

assign instr_field.funct7 = i[31:25];
assign instr_field.funct3 = i[14:12];
assign instr_field.rs2 = i[24:20];
assign instr_field.rs1 = i[19:15];
assign instr_field.rd = i[11:7];
assign instr_field.opcode = i[6:0];
assign instr_field.imm_i = i[31:20];
assign instr_field.imm_s = { i[31:25], i[11:7]};
assign instr_field.imm_b = { i[31], i[7:6], i[30:25], i[11:8]};
assign instr_field.imm_u = i[31:12];
assign instr_field.imm_j = {i[31], i[19:12], i[20], i[30:21]};

// riscv-spec 2.2 Table 19.1: RISC-V base opcode map
assign _0_0_x = !i[6] & !i[5];
assign _0_1_x = !i[6] & i[5];
assign _1_0_x = i[6] & !i[5];
assign _1_1_x = i[6] & i[5];

assign x_0_0_0 = !i[4] & !i[3] & !i[2];
assign x_0_0_1 = !i[4] & !i[3] & i[2];
assign x_0_1_0 = !i[4] & i[3] & !i[2];
assign x_0_1_1 = !i[4] & i[3] & i[2];
assign x_1_0_0 = i[4] & !i[3] & !i[2];
assign x_1_0_1 = i[4] & !i[3] & i[2];
assign x_1_1_0 = i[4] & i[3] & !i[2];
assign x_1_1_1 = i[4] & i[3] & i[2];

assign opcode_map.LOAD = _0_0_x & x_0_0_0;
assign opcode_map.STORE = _0_1_x & x_0_0_0;
assign opcode_map.MADD = _1_0_x & x_0_0_0;
assign opcode_map.BRANCH = _1_1_x & x_0_0_0;

assign opcode_map.LOAD_FP = _0_0_x & x_0_0_1;
assign opcode_map.STORE_FP = _0_1_x & x_0_0_1;
assign opcode_map.MSUB = _1_0_x & x_0_0_1;
assign opcode_map.JALR = _1_1_x & x_0_0_1;

assign opcode_map.NMSUB = _1_0_x & x_0_1_0;

assign opcode_map.MISC_MEM = _0_0_x & x_0_1_1;
assign opcode_map.AMO = _0_1_x & x_0_1_1;
assign opcode_map.NMADD = _1_0_x & x_0_1_1;
assign opcode_map.JAL = _1_1_x & x_0_1_1;

assign opcode_map.OP_IMM = _0_0_x & x_1_0_0;
assign opcode_map.OP = _0_1_x & x_1_0_0;
assign opcode_map.OP_FP = _1_0_x & x_1_0_0;
assign opcode_map.SYSTEM = _1_1_x & x_1_0_0;

assign opcode_map.AUIPC = _0_0_x & x_1_0_1;
assign opcode_map.LUI = _0_1_x & x_1_0_1;

assign opcode_map.OP_IMM_32 = _0_0_x & x_1_1_1;
assign opcode_map.OP_32 = _0_1_x & x_1_1_1;

//end riscv-spec 2.2 Table 19.1: RISC-V base opcode map

endmodule



typedef struct {
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
} regval;

module ex(
    input regval reg_val_pkt,
    input instr_field i_field_pkt,
    output opcode_map op_decode_pkt
);

    logic use_alu;
    logic write_rd;
    logic write_pc;
    logic read_mem;
    logic read_rs1;
    logic read_rs2;
    logic use_rs1;
    logic use_rs2;
    
    assign use_alu = op_decode_pkt.OP_IMM | op_decode_pkt.AUIPC | 
                    op_decode_pkt.OP | op_decode_pkt.JAL |
                    op_decode_pkt.JALR | op_decode_pkt.BRANCH | op_decode_pkt.LOAD | op_decode_pkt.STORE;

    assign use_plus4 = op_decode_pkt.JAL | op_decode_pkt.JALR;

    assign read_rs1 = op_decode_pkt.OP | op_decode_pkt.JALR | op_decode_pkt.BRANCH | op_decode_pkt.LOAD | op_decode_pkt.STORE;
    assign read_rs2 = op_decode_pkt.OP | op_decode_pkt.BRANCH | op_decode_pkt.STORE;

    assign write_rd = op_decode_pkt.OP | op_decode_pkt.OP_IMM | op_decode_pkt.LUI | op_decode_pkt.AUIPC | op_decode_pkt.LOAD;
    assign write_pc = op_decode_pkt.JAL | op_decode_pkt.JALR | op_decode_pkt.BRANCH;

    assign read_mem = op_decode_pkt.LOAD;
    assign write_mem = op_decode_pkt.STORE;


endmodule



module mem_32bit (
    input logic[31:0] rd_addr,
    input logic[31:0] wr_addr,
    input logic[31:0] wr_data,
    output logic[31:0] rd_data,

    input logic wren,
    input logic clk

);
    // solve 4 * x byte = 10 kB
    logic [31:0] internal_mem [0:2560-1];

    // behavioral
    // write operation
    always_ff @ (posedge clk) begin
        if (wren) begin
            internal_mem[wr_addr] <= wr_data;
        else begin
            internal_mem[wr_addr] <= internal_mem[wr_addr];
        end
    end

    // read operation
    always_ff @ (posedge clk) begin
        rd_data <= internal_mem[rd_addr];
    end

endmodule


module tb(
    input logic clk
);

    logic 

    // instr_mem

    // data_mem

    // cpu

endmodule