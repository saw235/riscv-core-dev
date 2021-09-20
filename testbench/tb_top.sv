module tb_top 
(
    input logic clk,
    input logic cpu_rstn
);

    mem_intf imem_if (.clk(clk));
    mem_intf dmem_if (.clk(clk));

    core cpu(
        .clk(clk), 
        .cpu_rstn(cpu_rstn),
        // imem intf
        .instr_rd_addr(imem_if.rd_addr),
        .instr_wr_addr(imem_if.wr_addr),
        .instr_wr_data(imem_if.wr_data),
        .instr_wr_strobe(imem_if.wr_strobe),
        .instr_rd_data(imem_if.rd_data),
        // dmem intf
        .data_rd_addr(dmem_if.rd_addr),
        .data_wr_addr(dmem_if.wr_addr),
        .data_wr_data(dmem_if.wr_data),
        .data_wr_strobe(dmem_if.wr_strobe),
        .data_rd_data(dmem_if.rd_data)
    );

    mem instr_mem (
        .intf(imem_if)
    );

    mem data_mem (
        .intf(dmem_if)
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
#(  parameter depth=256,
    parameter memfile = "")
(
    mem_intf.slave intf
);

   logic [31:0] mem [0:depth-1] /* verilator public */;

   always @(posedge intf.clk) begin
      if (intf.wr_strobe[0]) mem[intf.wr_addr][7:0]   <= intf.rd_data[7:0];
      if (intf.wr_strobe[1]) mem[intf.wr_addr][15:8]  <= intf.rd_data[15:8];
      if (intf.wr_strobe[2]) mem[intf.wr_addr][23:16] <= intf.rd_data[23:16];
      if (intf.wr_strobe[3]) mem[intf.wr_addr][31:24] <= intf.rd_data[31:24];
      intf.rd_data <= mem[intf.rd_addr];
   end

   generate
      initial
	if(memfile != "") begin
	   $display("Preloading %m from %s", memfile);
	   $readmemh(memfile, mem);
	end
   endgenerate

endmodule