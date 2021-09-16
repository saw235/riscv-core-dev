`ifdef FORMAL
    `include "prim_assert.sv"
`endif

`include "typedef.svh"
`include "defines.svh"


module decoder
(
    input logic [31:0] i, // instruction
    output instr_field i_field_pkt,
    output opcode_map op_decode_pkt
);

    logic _0_0_x;
    logic _0_1_x;
    logic _1_0_x;
    logic _1_1_x;
    logic x_0_0_0;
    logic x_0_0_1;
    logic x_0_1_0;
    logic x_0_1_1;
    logic x_1_0_0;
    logic x_1_0_1;
    logic x_1_1_0;
    logic x_1_1_1;

    // .extract
    // funct7 = 31..25
    // funct3 = 14..12
    // rs2 = 24..20
    // rs1 = 19..15
    // rd = 11..7
    // opcode = 6..0
    // imm_i = 31..20
    // imm_s = 31..25 11..7
    // imm_b = 31 7 30..25 11..8   = 1 + 1 + 6 + 4
    // imm_u = 31..12
    // imm_j = 31 19..12 20 30..21   = 1 + 8 + 1 + 10

    assign i_field_pkt.funct7 = i[31:25];
    assign i_field_pkt.funct3 = i[14:12];
    assign i_field_pkt.rs2 = i[24:20];
    assign i_field_pkt.rs1 = i[19:15];
    assign i_field_pkt.rd = i[11:7];
    assign i_field_pkt.opcode = i[6:0];
    assign i_field_pkt.imm_i = i[31:20];
    assign i_field_pkt.imm_s = { i[31:25], i[11:7]};
    assign i_field_pkt.imm_b = { i[31], i[7], i[30:25], i[11:8]};
    assign i_field_pkt.imm_u = i[31:12];
    assign i_field_pkt.imm_j = {i[31], i[19:12], i[20], i[30:21]};

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

    assign op_decode_pkt.LOAD = _0_0_x & x_0_0_0;
    assign op_decode_pkt.STORE = _0_1_x & x_0_0_0;
    assign op_decode_pkt.MADD = _1_0_x & x_0_0_0;
    assign op_decode_pkt.BRANCH = _1_1_x & x_0_0_0;

    assign op_decode_pkt.LOAD_FP = _0_0_x & x_0_0_1;
    assign op_decode_pkt.STORE_FP = _0_1_x & x_0_0_1;
    assign op_decode_pkt.MSUB = _1_0_x & x_0_0_1;
    assign op_decode_pkt.JALR = _1_1_x & x_0_0_1;

    assign op_decode_pkt.NMSUB = _1_0_x & x_0_1_0;

    assign op_decode_pkt.MISC_MEM = _0_0_x & x_0_1_1;
    assign op_decode_pkt.AMO = _0_1_x & x_0_1_1;
    assign op_decode_pkt.NMADD = _1_0_x & x_0_1_1;
    assign op_decode_pkt.JAL = _1_1_x & x_0_1_1;

    assign op_decode_pkt.OP_IMM = _0_0_x & x_1_0_0;
    assign op_decode_pkt.OP = _0_1_x & x_1_0_0;
    assign op_decode_pkt.OP_FP = _1_0_x & x_1_0_0;
    assign op_decode_pkt.SYSTEM = _1_1_x & x_1_0_0;

    assign op_decode_pkt.AUIPC = _0_0_x & x_1_0_1;
    assign op_decode_pkt.LUI = _0_1_x & x_1_0_1;

    assign op_decode_pkt.OP_IMM_32 = _0_0_x & x_1_1_1;
    assign op_decode_pkt.OP_32 = _0_1_x & x_1_1_1;

    //end riscv-spec 2.2 Table 19.1: RISC-V base opcode map


    `ifdef FORMAL
        `ASSUME_I(rv32i_lowbits, i[1:0] == 2'b11)
        `ASSERT_I(op_decode_exclusive, (op_decode_pkt == 0 | $onehot(op_decode_pkt)))
    `endif


endmodule


// module ex 
// (
//     input regval reg_val_pkt,
//     input instr_field i_field_pkt,
//     output opcode_map op_decode_pkt
// );

//     logic use_alu;
//     logic write_rd;
//     logic write_pc;
//     logic read_mem;
//     logic read_rs1;
//     logic read_rs2;
//     logic use_rs1;
//     logic use_rs2;
    
//     assign use_alu = op_decode_pkt.OP_IMM | op_decode_pkt.AUIPC | 
//                     op_decode_pkt.OP | op_decode_pkt.JAL |
//                     op_decode_pkt.JALR | op_decode_pkt.BRANCH | op_decode_pkt.LOAD | op_decode_pkt.STORE;

//     assign use_plus4 = op_decode_pkt.JAL | op_decode_pkt.JALR;

//     assign read_rs1 = op_decode_pkt.OP | op_decode_pkt.JALR | op_decode_pkt.BRANCH | op_decode_pkt.LOAD | op_decode_pkt.STORE;
//     assign read_rs2 = op_decode_pkt.OP | op_decode_pkt.BRANCH | op_decode_pkt.STORE;

//     assign write_rd = op_decode_pkt.OP | op_decode_pkt.OP_IMM | op_decode_pkt.LUI | op_decode_pkt.AUIPC | op_decode_pkt.LOAD;
//     assign write_pc = op_decode_pkt.JAL | op_decode_pkt.JALR | op_decode_pkt.BRANCH;

//     assign read_mem = op_decode_pkt.LOAD;
//     assign write_mem = op_decode_pkt.STORE;


// endmodule
