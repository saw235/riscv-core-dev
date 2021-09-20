
interface mem_intf #( parameter depth=256)
(
    input logic clk
);
    logic [$clog2(depth)-1:0] rd_addr;
    logic [$clog2(depth)-1:0] wr_addr;
    logic [31:0] wr_data;
    logic [3:0] wr_strobe;
    logic [31:0] rd_data;

    modport slave(
        input rd_addr, wr_addr, wr_data, wr_strobe, clk,
        output rd_data
    );

    modport master(
        output rd_addr, wr_addr, wr_data, wr_strobe,
        input rd_data
    );
endinterface