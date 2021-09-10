module tb_top(
    input clk,
    input cpu_rstn
);

    core cpu(
        .clk(clk),
        .cpu_rstn(cpu_rstn)
    );


    int cycle = 0;
    always @(posedge clk) begin
        cycle = cycle + 1;
        $display("cycle\t:%32d", cycle);
        $display("pc\t:%32d", cpu.current_pc);
    end

endmodule

