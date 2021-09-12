module tb_top 
(
    input logic clk,
    input logic cpu_rstn
);

    mem_intf imem_if (.clk(clk));

    core cpu(
        .clk(clk), 
        .cpu_rstn(cpu_rstn),
        .rd_addr(imem_if.rd_addr),
        .wr_addr(imem_if.wr_addr),
        .wr_data(imem_if.wr_data),
        .wren(imem_if.wren),
        .rd_data(imem_if.rd_data)
    );

    mem instr_mem (
        .intf(imem_if)
    );

    int cycle = 0;
    always @(posedge clk) begin
        cycle = cycle + 1;
        $display("cycle\t:%32d", cycle);
        $display("pc\t:%32d", cpu.current_pc);

        // TEMP
        if (cycle == 100) $finish();
    end

endmodule

// simple behavioral ram model
// not meant for synthesis
module mem 
#(
    parameter integer RAMDEPTH = 2 ** 10,  
    parameter integer BUSWIDTH = 32,
    parameter integer ADDRWIDTH = 32
)(
    mem_intf.slave intf
);

    logic [BUSWIDTH-1:0] local_mem [0:RAMDEPTH-1];
    
    always_ff @(posedge intf.clk) begin
        intf.rd_data <= local_mem[intf.rd_addr];

        if (intf.wren) begin
            local_mem[intf.wr_addr] <= intf.wr_data;
        end
    end

endmodule