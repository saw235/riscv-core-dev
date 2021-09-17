// TEMP - Workaround for now since sv2v in place have some deficiencies
`include "defines.svh"

`include "registers.svh"
`include "typedef.svh"

module core
(
    input logic clk,
    input logic cpu_rstn,

    // master mem intf
    output logic [`ADDRWIDTH-1:0] rd_addr,
    output logic [`ADDRWIDTH-1:0] wr_addr,
    output logic [`BUSWIDTH-1:0] wr_data,
    output logic wren,

    input logic [`BUSWIDTH-1:0] rd_data
);

    // Front-End signals (Fetch + Decode)
    logic [`XLEN-1:0] fetch_addr;
    logic fetch_addr_misaligned;
    logic next_pc_sel;

    logic [`XLEN-1:0] current_pc;
    logic [`XLEN-1:0] next_pc;
    logic [`XLEN-1:0] pc_plus_4;
    logic [`XLEN-1:0] instruction;

    logic [`XLEN-1:0] target_address;

    instr_field i_field_pkt;
    opcode_map op_decode_pkt;
    
    // Back-end signals (Ex + Mem)

    logic [`XLEN-1:0] alu_a;
    logic [`XLEN-1:0] alu_b;
    logic [`XLEN-1:0] alu_result;
    alu_op_t alu_op;

    logic [2:0] alu_b_select;

    regval_t regval;

    // Front-End logic (Next PC)
    assign target_address = 32'b0;

    assign pc_plus_4 = current_pc + 4; 
    assign fetch_addr = current_pc;
    assign next_pc = next_pc_sel ? target_address : pc_plus_4;
    
    // instruction address should be located at 32 bit boundary, 
    // ie divisible by 4 byte
    // alignment implies => fetch_addr & 2^2-1 == 0 
    assign fetch_addr_misaligned = fetch_addr[0] | fetch_addr[1] | fetch_addr[2];
    assign next_pc_sel = 1'b0; // temp for now

    // Start behavioral ram assignments
    // TODO use actual bus interface or NoC architecture
    assign rd_addr = current_pc;

    // Don't care about writes to instruction - mem for now just initialize to 0 
    assign wr_addr = 0;
    assign wr_data = 0; 
    assign wren = 0; 
    assign instruction = rd_data;
    // End behavioral ram assignments

    `FF(current_pc, next_pc, 0, clk, cpu_rstn);

    // Back-End Logic
    
    // alias for immediates
    logic [$bits(i_field_pkt.imm_i)-1:0] offset_i;
    logic [$bits(i_field_pkt.imm_s)-1:0] offset_s;
    logic [$bits(i_field_pkt.imm_b)-1:0] offset_b;

    assign offset_i = i_field_pkt.imm_i;
    assign offset_s = i_field_pkt.imm_s;
    assign offset_b = i_field_pkt.imm_b;

    assign alu_a = regval.rs1_val; 

    always_comb begin: alu_rs2_sel_mux
        localparam offset_i_nbits = $bits(offset_i);
        localparam offset_s_nbits = $bits(offset_s);
        localparam offset_b_nbits = $bits(offset_b);

        localparam sign_extend_i_nbits = $bits(alu_b) - offset_i_nbits;
        localparam sign_extend_s_nbits = $bits(alu_b) - offset_s_nbits;
        localparam sign_extend_b_nbits = $bits(alu_b) - offset_b_nbits;

        unique case (alu_b_select)
            3'b000 : alu_b = regval.rs2_val;
            3'b001 : alu_b = {i_field_pkt.imm_u, 12'b0};
            3'b010 : alu_b = {{sign_extend_i_nbits{offset_i[offset_i_nbits-1]}}, offset_i};
            3'b011 : alu_b = {{sign_extend_s_nbits{offset_s[offset_s_nbits-1]}}, offset_s};
            3'b100 : alu_b = {{sign_extend_b_nbits{offset_b[offset_b_nbits-1]}}, offset_b};
            default : alu_b = {$bits(alu_b){1'bx}};
        endcase
    end

    always_comb begin : alu_op_decode

        logic alu_use_qualifier;

        logic alu_op_and;
        logic alu_op_or;
        logic alu_op_xor;
        logic alu_op_slt;
        logic alu_op_sltu;
        logic alu_op_sll;
        logic alu_op_srl;
        logic alu_op_sra;
        logic alu_op_add;

        // use alu only for these operation
        alu_use_qualifier = op_decode_pkt.OP | op_decode_pkt.OP_IMM | op_decode_pkt.LUI | op_decode_pkt.AUIPC;
        
        alu_op_add = {1'b0, i_field_pkt.funct3} == ADD;
        alu_op_or = {1'b0, i_field_pkt.funct3} == OR;
        alu_op_xor = {1'b0, i_field_pkt.funct3} == XOR;
        

        
        
    end

    always_comb begin : regfile_wr_data_mux

    end

    always_comb begin : regfile_wr_en_control
        
    end

    // Module Instantiation And Connections
    decoder decode(
        .i(instruction),
        .i_field_pkt(i_field_pkt),
        .op_decode_pkt(op_decode_pkt)
    );

    alu alu(
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result)
    );

    regfile_32b regfile(
        .r0addr(i_field_pkt.rs1),
        .r1addr(i_field_pkt.rs2),
        .r0data(regval.rs1_val),
        .r1data(regval.rs2_val),
        .waddr(i_field_pkt.rd),
        .wdata(regfile_wr_data),
        .wren(regfile_wr_en),
        .clk(clk)
    );

    `ifdef FORMAL
    `ifdef YOSYS
        `include "formal_tb_frag.svh"
    `endif
    `endif

endmodule
