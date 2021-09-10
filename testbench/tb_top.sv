module tb_top(
    input clk,
    input cpu_rstn
);

    core cpu(
        .clk(clk),
        .cpu_rstn(cpu_rstn)
    );

    // // load instruction into mem
    // initial begin
    //     $readmemh("hex_memory_file.mem", memory_array,
    // end

endmodule