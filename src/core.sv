// TEMP - Workaround for now since sv2v in place have some deficiencies
`include "defines.svh"

`include "registers.svh"
`include "typedef.svh"

module core
(
    input logic clk,
    input logic cpu_rstn,

    // master instr mem intf
    output logic [`ADDRWIDTH-1:0] instr_rd_addr,
    output logic [`ADDRWIDTH-1:0] instr_wr_addr,
    output logic [`BUSWIDTH-1:0] instr_wr_data,
    input logic [`BUSWIDTH-1:0] instr_rd_data,
    output logic instr_wren,

    // master data mem intf
    output logic [`ADDRWIDTH-1:0] data_rd_addr,
    output logic [`ADDRWIDTH-1:0] data_wr_addr,
    output logic [`BUSWIDTH-1:0] data_wr_data,
    input logic [`BUSWIDTH-1:0] data_rd_data,
    output logic data_wren

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
    instruction_decode_t instruction_decode_pkt;
    logic is_illegal_instruction;

    // getting the number of bits to sign extends
    localparam offset_i_nbits = $bits(offset_i);
    localparam offset_j_nbits = $bits(offset_j);
    localparam offset_s_nbits = $bits(offset_s);
    localparam offset_b_nbits = $bits(offset_b);

    localparam sign_extend_i_nbits = $bits(alu_b) - offset_i_nbits;
    localparam sign_extend_j_nbits = $bits(alu_b) - offset_j_nbits;
    localparam sign_extend_s_nbits = $bits(alu_b) - offset_s_nbits;
    localparam sign_extend_b_nbits = $bits(alu_b) - offset_b_nbits;

    // alias for immediates
    logic [$bits(i_field_pkt.imm_i)-1:0] offset_i;
    logic [$bits(i_field_pkt.imm_j)-1:0] offset_j;
    logic [$bits(i_field_pkt.imm_s)-1:0] offset_s;
    logic [$bits(i_field_pkt.imm_b)-1:0] offset_b;
    
    // Back-end signals (Ex + Mem + WB)

    logic [`XLEN-1:0] regfile_wr_data;

    logic [`XLEN-1:0] alu_a;
    logic [`XLEN-1:0] alu_b;
    logic [`XLEN-1:0] alu_result;
    alu_op_t alu_op;
    regval_t regval;

    logic alu_eq;
    logic alu_ne;
    logic alu_lt;
    logic alu_ltu;
    logic alu_ge;
    logic alu_geu;

    logic [`XLEN-1:0] return_address;
    logic [`XLEN-1:0] address_generate;
    logic [`XLEN-1:0] link_address;

    // control signals
    logic alu_b_use_imm_i;
    logic next_pc_jump; 
    logic regfile_use_imm_u;
    logic regfile_use_link_address;
    logic regfile_use_alu_result;
    logic use_aligned_address_generate;
    logic use_raw_address_generate;
    logic adder_use_imm_u;
    logic adder_use_offset_j;
    logic adder_use_offset_i;
    logic adder_use_offset_b;
    logic regfile_wr_en;


    // Front-End logic (Next PC)
    
    logic target_address_sel;

    assign target_address_sel = use_aligned_address_generate;
    assign target_address = target_address_sel ? address_generate & 32'hFFFE : address_generate;

    always_comb begin : address_gen
        logic [3:0] address_generate_sel;

        address_generate_sel = {adder_use_imm_u, adder_use_offset_b, adder_use_offset_i, adder_use_offset_j};       

        // may hide x's due to X-optimism
        unique case (address_generate_sel)
            4'b1000: address_generate = current_pc + {i_field_pkt.imm_u, 12'h000};
            4'b0100: address_generate = current_pc + {{sign_extend_b_nbits{offset_b[offset_b_nbits-1]}}, offset_b};
            4'b0010: address_generate = current_pc + {{sign_extend_i_nbits{offset_i[offset_i_nbits-1]}}, offset_i};
            4'b0001: address_generate = current_pc + {{sign_extend_j_nbits{offset_j[offset_j_nbits-1]}}, offset_j};
            default : address_generate = current_pc + {i_field_pkt.imm_u, 12'h000};
        endcase
    end
        


    assign pc_plus_4 = current_pc + 4; 
    assign fetch_addr = current_pc;
    assign next_pc = next_pc_sel ? target_address : pc_plus_4;
    
    // instruction address should be located at 32 bit boundary, 
    // ie divisible by 4 byte
    // alignment implies => fetch_addr & 2^2-1 == 0 
    assign fetch_addr_misaligned = fetch_addr[0] | fetch_addr[1] | fetch_addr[2];
    assign next_pc_sel = op_decode_pkt.BRANCH | op_decode_pkt.JAL | op_decode_pkt.JALR; // temp for now

    // Start behavioral ram assignments
    // TODO use actual bus interface or NoC architecture
    assign instr_rd_addr = current_pc;

    // Don't care about writes to instruction - mem for now just initialize to 0 
    assign instr_wr_addr = 0;
    assign instr_wr_data = 0; 
    assign instr_wren = 0; 
    assign instruction = instr_rd_data;
    // End behavioral ram assignments

    `FF(current_pc, next_pc, 0, clk, cpu_rstn);

    // Back-End Logic
    assign offset_i = i_field_pkt.imm_i;
    assign offset_j = i_field_pkt.imm_j;
    assign offset_s = i_field_pkt.imm_s;
    assign offset_b = i_field_pkt.imm_b;

    assign alu_a = regval.rs1_val;

    always_comb begin: controls
        // control signal is a function of (opcode, funct3, funct7, imm, current state)
        
        alu_b_use_imm_i = instruction_decode_pkt.ADDI
                            | instruction_decode_pkt.SLTI
                            | instruction_decode_pkt.SLTIU
                            | instruction_decode_pkt.XORI
                            | instruction_decode_pkt.ORI
                            | instruction_decode_pkt.ANDI
                            | instruction_decode_pkt.SLLI
                            | instruction_decode_pkt.SRLI
                            | instruction_decode_pkt.SRAI;
                            
        next_pc_jump = instruction_decode_pkt.JAL | instruction_decode_pkt.JALR 
                            | (instruction_decode_pkt.BEQ & alu_eq)
                            | (instruction_decode_pkt.BNE & alu_ne)
                            | (instruction_decode_pkt.BLT & alu_lt)
                            | (instruction_decode_pkt.BGE & alu_ge)
                            | (instruction_decode_pkt.BLTU & alu_ltu)
                            | (instruction_decode_pkt.BGEU & alu_geu);

        regfile_use_imm_u = instruction_decode_pkt.LUI;
        regfile_use_link_address = instruction_decode_pkt.AUIPC 
                                | instruction_decode_pkt.JAL 
                                | instruction_decode_pkt.JALR ;
        regfile_use_alu_result = ~(regfile_use_imm_u & regfile_use_link_address);

        use_aligned_address_generate = instruction_decode_pkt.JALR;
        use_raw_address_generate = ~use_aligned_address_generate;

        adder_use_imm_u = instruction_decode_pkt.AUIPC;
        adder_use_offset_j = instruction_decode_pkt.JAL;
        adder_use_offset_i = instruction_decode_pkt.JALR;
        adder_use_offset_b = op_decode_pkt.BRANCH;

        regfile_wr_en = ~is_illegal_instruction 
                        & (instruction_decode_pkt.LUI 
                        | instruction_decode_pkt.JAL 
                        | instruction_decode_pkt.JALR
                        | op_decode_pkt.LOAD
                        | op_decode_pkt.OP
                        | op_decode_pkt.OP_IMM);

        // dmem_write_req = ~is_illegal_instruction & op_decode_pkt.STORE;

    end

    always_comb begin: alu_rs2_sel_mux

        logic alu_b_select;

        alu_b_select = alu_b_use_imm_i;

        unique case (alu_b_select)
            1'b0 : alu_b = regval.rs2_val;
            1'b1 : alu_b = {{sign_extend_i_nbits{offset_i[offset_i_nbits-1]}}, offset_i};
            default : alu_b = 'x;
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

        // use alu only for these operations
        alu_use_qualifier = op_decode_pkt.OP | op_decode_pkt.OP_IMM 
                            | op_decode_pkt.LUI | op_decode_pkt.AUIPC 
                            | op_decode_pkt.BRANCH;
        
        alu_op_add = instruction_decode_pkt.ADD | instruction_decode_pkt.ADDI;        
        alu_op_or = instruction_decode_pkt.OR | instruction_decode_pkt.ORI;
        alu_op_xor = instruction_decode_pkt.XOR | instruction_decode_pkt.XORI;
        alu_op_and = instruction_decode_pkt.AND | instruction_decode_pkt.ANDI;

        alu_op_slt = instruction_decode_pkt.SLT | instruction_decode_pkt.SLTI;
        alu_op_sltu = instruction_decode_pkt.SLTU | instruction_decode_pkt.SLTIU;
        
        alu_op_sll = instruction_decode_pkt.SLL | instruction_decode_pkt.SLLI;
        alu_op_srl = instruction_decode_pkt.SRL | instruction_decode_pkt.SRLI;
        alu_op_sra = instruction_decode_pkt.SRA | instruction_decode_pkt.SRAI;
        
        if (alu_use_qualifier) begin
            unique case (1'b1)
                alu_op_add : alu_op = ADD;
                alu_op_or : alu_op = OR;
                alu_op_xor : alu_op = XOR;
                alu_op_and : alu_op = AND;
                alu_op_slt : alu_op = SLT;
                alu_op_sltu : alu_op = SLTU;
                alu_op_sll : alu_op = SLL;
                alu_op_srl : alu_op = SRL;
                alu_op_sra : alu_op = SRA;
                default : alu_op = NOP;
            endcase 
        end else begin
            alu_op = NOP;
        end
    end

    always_comb begin : regfile_wr_data_mux

        link_address = target_address + 4;

        // may hide x's due to X-optimism
        unique case ({regfile_use_imm_u, regfile_use_link_address, regfile_use_alu_result})
            3'b100 : regfile_wr_data = {i_field_pkt.imm_u, 12'b0};
            3'b010 : regfile_wr_data = alu_result;
            3'b001 : regfile_wr_data = link_address;
            default : regfile_wr_data = alu_result;
        endcase
    end

    // Module Instantiation And Connections
    decoder decode(
        .i(instruction),
        .i_field_pkt(i_field_pkt),
        .op_decode_pkt(op_decode_pkt),
        .instruction_decode_pkt(instruction_decode_pkt),
        .illegal_instruction(is_illegal_instruction)
    );

    alu alu(
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result),
        .EQ(alu_eq),
        .NE(alu_ne),
        .LT(alu_lt),
        .LTU(alu_ltu),
        .GE(alu_ge),
        .GEU(alu_geu)
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
